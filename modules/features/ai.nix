{ ... }:
{
  # llama.cpp in *router mode*: one `llama-server` process that discovers GGUFs,
  # loads/unloads them on demand and exposes an OpenAI-compatible API. This is the
  # path Pi integrates with natively (`/llama` to download + load models, `/login
  # llama.cpp` or LLAMA_BASE_URL to point at this host over the tailnet).
  flake.nixosModules.ai =
    { pkgs, ... }:
    {
      config = {
        services.llama-cpp = {
          enable = true;

          settings = {
            # Every interface, but only tailscale0 gets through the firewall below —
            # the tailnet IP is not known at build time so it cannot be bound directly.
            host = "0.0.0.0";
            # 8080 is already taken by the qbittorrent forward out of the VPN netns.
            port = 8090;

            # Router mode is selected by the ABSENCE of `model`/`-m`. Do not add one:
            # passing a model drops the server into single-model mode and Pi's /llama
            # stops working.
            #
            # Models land in LLAMA_CACHE (/var/cache/llama-cpp, persisted below) when
            # pulled with Pi's /llama, so nothing needs declaring here.

            # 7.5G of RAM shared with jellyfin/nextcloud/hass. One model resident.
            models-max = 1;

            # Chat templates + tool calling. Pi is an agent; without this it cannot
            # call tools.
            jinja = true;

            # i7-8565U is 4 cores / 8 threads. Hyperthreads do not help a
            # memory-bandwidth-bound workload and steal from the rest of the box.
            threads = 4;

            # Inherited by every model instance the router spawns.
            ctx-size = 16384;
            flash-attn = "on";
            # Halves KV cache RAM; needs flash attention.
            cache-type-k = "q8_0";
            cache-type-v = "q8_0";
          };
        };

        # Reachable from the tailnet only. Nothing is opened on wlan0.
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 8090 ];

        # The unit runs under DynamicUser, so State/CacheDirectory land in the
        # `private` subdirs. /var/cache is on the tmpfs root — without this the GGUFs
        # are re-downloaded on every boot.
        environment.persistence."/persist".directories = [
          "/var/lib/private/llama-cpp"
          "/var/cache/private/llama-cpp"
        ];

        environment.systemPackages = [ pkgs.llama-cpp ];
      };
    };
}
