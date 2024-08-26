{ config, lib, pkgs, nixpkgs, lanzaboote, nixos-hardware, ... }:
# let
  # sources = import ./nix/sources.nix;
  # lanzaboote = import sources.lanzaboote;
  # unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };

# in
{
  imports =
    [ # Include the results of the hardware scan.
       # lanzaboote.nixosModules.lanzaboote
      ./hardware-configuration.nix
      # <nixos-hardware/lenovo/thinkpad/t490>
      # (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
    ];

  # enable bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-run"
    "discord"
    "vscode"
    "steamcmd"
    "obsidian"
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  networking.hostName = "superthinker"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;
  programs.hyprlock.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Enable the X11 windowing system.
  # services.xserver = {
  #   enable = true;
  #   libinput.touchpad.naturalScrolling = true;
  #   windowManager.dwm.enable = true;
  #   displayManager.startx.enable = true;
  # };

  # hardware.opengl.enable = true;

  # services.xserver.windowManager.dwm.package = pkgs.dwm.overrideAttrs {
  #   src = /etc/dwm/source;
  # };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  hardware.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services = {
    openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PasswordAuthentication = true;
      };
    };
    # vscode-server = {
    #   enable = true;
    # };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tlepine = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "wireshark" ];
    packages = with pkgs; [
      htop
      firefox
      remmina
      tio
      git
      gh
      gnumake
      brightnessctl
      docker-compose
      kubectl
      kind
      calibre
      swww
      kubernetes-helm
      discord
      libreoffice-qt
      containerlab
      hyprshot
      prismlauncher
      rpi-imager
      vscode
      arduino
      steamcmd
      pulseview
      telegram-desktop
      ruby
      k9s
      lazygit
      taskwarrior
      taskwarrior-tui
      rofimoji
      obsidian
    ];
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.wireshark = {
    enable = true;
  };

  # programs.zsh = {
  #   enable = true;
  #   enableCompletion = true;
  #   autosuggestions.enable = true;
  #   syntaxHighlighting.enable = true;

  #   shellAliases = {
  #     sw = "sudo nixos-rebuild --flake /etc/nixos#superthinker switch";
  #   };

  #   ohMyZsh = {
  #     # bureau
  #     enable = true;
  #     theme = "afowler";
  #   };

  #   histSize = 10000;
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    networkmanager-openvpn
    wget
    # unstable.hyprcursor # not working:(
    niv		# nixos dependency manager, alternative to Flakes
    st		# minimal terminal
    sbctl 	# this is a tool to manage SecureBoot keys
    curl
    dmenu
    xorg.xinit
    # unstable.alacritty # when version 0.13.1 is stable, remove from unstable
    smile
    wl-clipboard-rs
    alacritty
    gcc
    waybar
    kanshi
    rofi-wayland
    inetutils
    hyprlock
    wlogout
    xdg-utils
    (pkgs.buildFHSUserEnv {
      name = "renpyfhs";
      runScript = "bash";
      targetPkgs = pkgs: with pkgs; [
        libGL
        python310
        alsa-lib
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

  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  

  # setup fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

   # services.greetd = {
   #   enable = true;
   #   settings = rec {
   #     hyprland = {
   #       command = "${pkgs.hyprland}/bin/Hyprland";
   #       user = "tlepine";
   #     };
   #     default_session = hyprland;
   #   };
   # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}
