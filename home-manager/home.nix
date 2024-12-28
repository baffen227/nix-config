# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  #inputs,
  #lib,
  #config,
  pkgs,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # Set your username
  home = {
    username = "baffen227";
    homeDirectory = "/home/baffen227";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [

    # ===== Browser =====
    chromium

    # ===== Communication =====
    element-desktop
    #telegram-desktop
    #discord
    teams-for-linux
    # For line us this chrome extensions:
    ## https://chromewebstore.google.com/detail/line/ophjlpahpchlmihnnnihgmmeilfjmjjc?hl=zh-TW

    # ===== Terminal =====
    alacritty
    alacritty-theme
    neofetch
    nnn # terminal file manager

    # ===== Media =====
    vlc
    ffmpeg
    obs-studio
    gimp-with-plugins
    libsForQt5.kdenlive
    inkscape-with-extensions
    libreoffice-fresh
    #steam
    appimage-run

    # ===== Networking =====
    wireshark
    nettools

    # ===== System Tools =====
    gparted
    ventoy-full
    mkcert
    # Used to check if an app is using Xwayland or Wayland
    xorg.xeyes
    docker-compose
    ttf-tw-moe
    # archives
    zip
    xz
    unzip
    p7zip
    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    #mtr # A network diagnostic tool
    #iperf3
    #dnsutils  # `dig` + `nslookup`
    #ldns # replacement of `dig`, it provide the command `drill`
    #aria2 # A lightweight multi-protocol & multi-source command-line download utility
    #socat # replacement of openbsd-netcat
    #nmap # A utility for network discovery and security auditing
    #ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    #hugo # static site generator
    glow # markdown previewer in terminal

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # ===== DEV ===== #
    # Postman Open-Source Alternative
    hoppscotch
    nixpkgs-fmt
    saleae-logic-2
    stm32cubemx
  ];

  # TODO: Some programs to be considered is at BTDL's nixos-work-config.

  programs = {

    # Enable home-manager and git
    home-manager.enable = true;

    # Configure git and lazygit
    git = {
      enable = true;
      userEmail = "baffen227@gmail.com";
      userName = "Harry Chen";
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          # showFileTree = false;

          theme = {
            activeBorderColor = [
              "blue"
              "bold"
            ];
            selectedLineBgColor = [ "white" ];
          };
        };
        git = {
          # Improves performance
          # https://github.com/jesseduffield/lazygit/issues/2875#issuecomment-1665376437
          log.order = "default";

          fetchAll = false;
        };
      };
    };

    # Configure zsh and oh-my-zsh
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "emacs";
      shellAliases = {
        ll = "ls -l";
        nvim = "nix run ~/Documents/nixvim-flake# --";
        # TODO: read variable hostName instead of hard-coded hostname
        update_system = "sudo nixos-rebuild switch --flake .#nixos";
        update_home = "home-manager switch --flake .#baffen227@nixos";
      };
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "history"
          "rust"
        ];
      };
    };

    # Enable and configure alacritty
    # https://alacritty.org/config-alacritty.html
    alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        window.startup_mode = "Maximized";
        scrolling.multiplier = 5;
        font = {
          normal = {
            family = "Hack Nerd Font Mono";
            style = "Regular";
          };
          size = 15;
        };
        colors.draw_bold_text_with_bright_colors = true;
        selection.save_to_clipboard = true;
      };
    };

    # Enable neovim
    # Use my nixvim-flake instead
    # neovim.enable = true;

    # Enable and configure VSCodium
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        arrterian.nix-env-selector
        jnoortheen.nix-ide
        rust-lang.rust-analyzer
        serayuzgur.crates
        tamasfe.even-better-toml
        vadimcn.vscode-lldb
        eamodio.gitlens
        mhutchie.git-graph
        aaron-bond.better-comments
        yzhang.markdown-all-in-one
        # bierner.github-markdown-preview
        vscodevim.vim
      ];
    };

  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
