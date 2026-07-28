{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # TODO: figure out what this is
  security.polkit.enable = true;

  # enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.extra-sandbox-paths = [ "/dev/kvm" ];

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    configurationLimit = 5; # limit boot entries
  };

  boot.loader.grub.memtest86.enable = true;

  networking.hostName = "superthinker"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ];
  };

  virtualisation.vmware.host.enable = true;
  virtualisation.waydroid = {
    enable = true;
    package = pkgs.waydroid-nftables;
  };

  environment.sessionVariables = {
    GIO_EXTRA_MODULES = [ "${pkgs.glib-networking}/lib/gio/modules" ];
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.niri = {
    enable = true;
  };

  programs.dms-shell = {
    enable = true;
  };

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # Modern Intel VA-API driver
      mesa # OpenGL/Vulkan support
    ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.geoclue2 = {
    enable = true;
    enableNmea = false;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.udev.extraRules = ''
    ACTION=="add" \
      , SUBSYSTEM=="net" \
      , ATTRS{manufacturer}=="reMarkable" \
      , ATTRS{idProduct}=="4010" \
      , ATTRS{idVendor}=="04b3" \
      , NAME="reMarkable_USB"
  '';

  services = {
    openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PasswordAuthentication = true;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tlepine = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "wireshark"
      "render"
      "video"
      "dialout"
      "plugdev"
    ];
    packages = with pkgs; [
      home-manager
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.wireshark = {
    enable = true;
  };

  hardware.opentabletdriver.enable = true;
  hardware.uinput.enable = true;
  boot.kernelModules = [ "uinput" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    git-crypt

    glib-networking
    gnome-network-displays
    networkmanager-openvpn
    wget
    playerctl
    niv # nixos dependency manager, alternative to Flakes
    st # minimal terminal
    sbctl # this is a tool to manage SecureBoot keys
    curl
    dmenu
    xorg.xinit
    smile
    wl-clipboard-rs
    alacritty
    gcc
    kanshi
    rofi
    inetutils
    hyprlock
    wlogout
    xdg-utils
    (pkgs.buildFHSEnv {
      name = "javafhs";
      runScript = "bash";
      targetPkgs =
        pkgs: with pkgs; [
          jdk21
          xorg.libXxf86vm
          libGL
          glib
          gtk3
          xorg.libXtst
          xorg.xwininfo
          xorg.xprop
          maven
          temurin-jre-bin
          runelite
        ];
    })
  ];

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            options = [ "NOPASSWD" ];
            command = "ALL";
          }
        ];
        users = [ "tlepine" ];
      }
    ];
  };

  programs.bash.shellAliases = {
    start = "Hyprland && logout";
    sw = "sudo nixos-rebuild --flake /etc/nixos#superthinker switch";
  };

  virtualisation.docker = {
    enableOnBoot = false;
    enable = true;
  };
  virtualisation.podman.enable = true;

  # setup fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.hurmit
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "tlepine";
      };
    };
  };

  programs.nix-ld.enable = true;

  # this is to avoid spamming log messages while tuigreet is open
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "tlepine" ];
  };

  networking.firewall = {
    enable = false;
  };

  environment.etc."1password/custom_allowed_browsers" = {
    mode = "0644";
    text = ''
      zen
    '';
  };

  services.udev.packages = [ pkgs.platformio-core.udev ];

  system.stateVersion = "24.11"; # Did you read the comment?

}
