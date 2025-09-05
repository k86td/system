{ config, lib, pkgs, cfg, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # <nixos-hardware/lenovo/thinkpad/t490>
      # (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
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
  security.pki.certificateFiles = if cfg.repoDecrypted then [
    ./secrets/trusted-ca1.pem
  ] else [];

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
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
  };

  networking.hostName = "superthinker"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  systemd.services.NetworkManager-wait-online.enable = false;

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

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
      mesa
      vpl-gpu-rt
    ];
  };

  # services.xserver.windowManager.dwm.package = pkgs.dwm.overrideAttrs {
  #   src = /etc/dwm/source;
  # };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.geoclue2 = {
    enable = true;
    enableNmea = false;
  };

  # Enable sound.
  # hardware.pulseaudio.enable = false;
  # nixpkgs.config.pulseaudio = false;

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
    extraGroups = [ "wheel" "docker" "wireshark" "render" "video" ];
    packages = with pkgs; [
      home-manager

      # htop
      # firefox
      # remmina
      # tio
      # git
      # gh
      # gnumake
      # brightnessctl
      # docker-compose
      # # kubectl
      # kind
      # # calibre
      # swww
      # kubernetes-helm
      # discord
      # libreoffice-qt
      # containerlab
      # hyprshot
      # prismlauncher
      # rpi-imager
      # vscode
      # arduino
      # steamcmd
      # pulseview
      # telegram-desktop
      # ruby
      # k9s
      # lazygit
      # taskwarrior3
      # taskwarrior-tui
      # rofimoji
      # obsidian
      # nwg-displays
      # hyprpaper
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

  services.openvpn.servers = if cfg.repoDecrypted then {
    BOSS = {
      config = builtins.readFile ./secrets/vpn/ebox-boss.ovpn;
      autoStart = false;
    };
  } else {};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    git-crypt

    networkmanager-openvpn
    wget
    playerctl
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
    (pkgs.buildFHSEnv {
      name = "javafhs";
      runScript = "bash";
      targetPkgs = pkgs: with pkgs; [
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
    (pkgs.buildFHSEnv {
      name = "renpyfhs310";
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

  virtualisation.docker = {
    enableOnBoot = false;
    enable = true;
  };
  virtualisation.podman.enable = true;
  

  # setup fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.hurmit
    fonts-tiempos
  ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
        user = "tlepine";
      };
    };
  };

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
  networking.firewall = {
    enable = false;
  };

  system.stateVersion = "24.11"; # Did you read the comment?

}
