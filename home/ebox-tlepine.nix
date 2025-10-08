{ config, pkgs, cfg, lib, ... }:
let
  username = "tlepine";
  homeDirectory = "/home/${username}";

  # Python environment with ansible-related packages
  python3WithAnsible = pkgs.python312.withPackages(ps: with ps; [
    kubernetes
    ansible-core  # Core ansible functionality
    pyyaml        # YAML processing (essential for ansible)
    jmespath      # JSON processing for ansible filters
    paramiko      # SSH connections
    cryptography  # Encryption/decryption support
    requests      # HTTP requests
    netaddr       # IP address manipulation
    dnspython     # DNS lookups
    hvac          # HashiCorp Vault integration
    pip           # Python package installer
  ]);
in
rec {
  imports = [
    ./modules/tmux.nix
    ./modules/vim.nix
    ./modules/taskwarrior.nix
    ./modules/nushell.nix
    ./modules/neovim
    ./modules/terminal.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home.username = "${username}";
  home.homeDirectory = "${homeDirectory}";

  home.stateVersion = "24.05";

  programs.nh = {
    enable = true;
    flake = "/etc/nixos";
  };

  home.packages = with pkgs; [
    git-crypt
    rustup
    nix-output-monitor
    claude-code
    nodejs_22

    govc
    talosctl
    cilium-cli
    butane

    glab

    # Ansible and related tools (using Python environment exclusively)
    ansible-lint      # Ansible playbook linting
    yamllint         # YAML file linting
    python3WithAnsible  # Python environment with ansible packages

    # Additional useful tools for ansible workflows
    jq               # JSON processing
    yq-go            # YAML processing
    sshpass          # Non-interactive SSH password auth
    rsync            # File synchronization
    
    lua-language-server

    go
    gopls
    operator-sdk
    kind
    kubernetes-helm

    openssh
    code-server
    gcc
    stow

    mustache-go

    #(pkgs.wrapHelm pkgs.kubernetes-helm {
    #  plugins = [
    #    pkgs.kubernetes-helmPlugins.helm-diff
    #  ];
    #})
    # kubernetes-helm
    #helmfile

    kubectl
    kubelogin-oidc
    k9s
    kind
    ripgrep

    nixd

    #argocd
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    "${homeDirectory}/.config/nix" = {
        source = ./files/nix;
        recursive = true;
    };
    "${homeDirectory}/.config/starship.toml" = {
        source = lib.mkForce ./files/starship.toml;
    };
    "${homeDirectory}/.claude/settings.json" = {
        source = ./files/claude/settings.json;
    };
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.shellAliases = {
    sw = "home-manager --flake /etc/nixos#ebox-tlepine switch";
    dev = "nix develop -c $env.SHELL";
  };

  programs.nushell = {
    extraConfig = ''
      $env.STARSHIP_SHELL = "nu"

      $env.PATH = '/home/tlepine/.nix-profile/bin' | append '/usr/bin' | append '/bin' | append '/mnt/wsl/docker-desktop/cli-tools/usr/bin'
      
      # TODO: use something more secure than writing to conf file
      # business env variable secrets
      ${builtins.concatStringsSep "\n" (builtins.attrValues 
        (
          builtins.mapAttrs (name: value: "$env.${name} = \"${toString value}\"") 
          (if cfg.repoDecrypted then import ../secrets/govc.nix else {} )
        ))}
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.lazygit = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Tristan Lepine";
    userEmail = "tristan.lepine@ebox.ca";
  };

  programs.neovim = {
    enable = true;
  };
}
