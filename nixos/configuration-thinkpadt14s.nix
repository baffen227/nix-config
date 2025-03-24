# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration-thinkpadt14s.nix
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
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Opinionated: disable global registry
        flake-registry = "";
        # Workaround for https://github.com/NixOS/nix/issues/9574
        nix-path = config.nix.nixPath;
      };
      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  # Add the rest of your current configuration

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking = {
    # Set your hostname
    # sample longer hostName = "FE-24415-BTDL-harrychen-LenovoThinkPadT14s-NixOs"
    hostName = "t14s";

    # Enables wireless support via wpa_supplicant.
    # wireless.enable = true;

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;
    firewall = {
      # Open ports in the firewall.
      allowedTCPPorts = [
        443
        80
      ];

      # if packets are still dropped, they will show up in dmesg
      logReversePathDrops = true;

      # Here is a trick to let our device route all traffice through Wireguard
      # cf: https://nixos.wiki/wiki/WireGuard
      # wireguard trips rpfilter up
      #extraCommands = ''
      #  ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN
      #  ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN
      #'';
      #extraStopCommands = ''
      #  ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51820 -j RETURN || true
      #  ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51820 -j RETURN || true
      #'';
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Taipei";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_ADDRESS = "zh_TW.UTF-8";
      LC_IDENTIFICATION = "zh_TW.UTF-8";
      LC_MEASUREMENT = "zh_TW.UTF-8";
      LC_MONETARY = "zh_TW.UTF-8";
      LC_NAME = "zh_TW.UTF-8";
      LC_NUMERIC = "zh_TW.UTF-8";
      LC_PAPER = "zh_TW.UTF-8";
      LC_TELEPHONE = "zh_TW.UTF-8";
      LC_TIME = "zh_TW.UTF-8";
    };

    inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chewing
        fcitx5-gtk
      ];
    };
  };

  # For fine grained Font control (can set a font per language!) see: https://nixos.wiki/wiki/Fonts
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      source-code-pro
      font-awesome
      (nerdfonts.override { fonts = [ "Hack" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [
          "Hack Nerd Font Mono"
          "Source Code Pro"
          "Noto Sans Mono CJK TC"
          "DejaVu Sans Mono"
        ];
        sansSerif = [
          "Noto Sans CJK TC"
          "DejaVu Sans"
        ];
        serif = [
          "Noto Serif CJK TC"
          "DejaVu Serif"
        ];
      };
    };
  };

  # system services
  services = {

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      # Display Manager
      displayManager = {
        # Gnome's display manager
        gdm.enable = true;
        # Tweak to make Display Link docks accept more monitors
        #sessionCommands = ''
        #  xrandr --setprovideroutputsource 2 0
        #'';
      };
      # Enable the GNOME Desktop Environment.
      desktopManager.gnome.enable = true;
      # DisplayLink Dock compatibility
      #videoDrivers = [
      #  "displaylink"
      #  "modesetting"
      #];
      # Keyboard Layout
      xkb.layout = "us";
      xkb.variant = "";
    };

    # Enable CUPS to print documents.
    printing = {
      enable = true;
      drivers = [
        pkgs.foomatic-db
        pkgs.foomatic-db-ppds
      ];
    };

    # Pipewire sound server
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # libinput.enable = true;

    # HTTP Server
    #nginx = {
    #  enable = true;
    #  recommendedProxySettings = true;
    #  recommendedTlsSettings = true;
    #  # other Nginx options
    #  virtualHosts."localhost.com" = {
    #    #enableACME = true;
    #    forceSSL = false;
    #    locations."/" = {
    #      proxyPass = "http://127.0.0.1:8080";
    #      proxyWebsockets = true; # needed if you need to use WebSocket
    #      extraConfig =
    #        # required when the target is also TLS server with multiple hosts
    #        "proxy_ssl_server_name on;"
    #        +
    #          # required when the server wants to use HTTP Authentication
    #          "proxy_pass_header Authorization;";
    #    };
    #  };
    #};

    # This setups a SSH server. Very important if you're setting up a headless system.
    # Feel free to remove if you don't need it.
    #openssh = {
    #  enable = true;
    #  settings = {
    #    # Opinionated: forbid root login through SSH.
    #    PermitRootLogin = "no";
    #    # Opinionated: use keys only.
    #    # Remove if you want to SSH using passwords
    #    PasswordAuthentication = false;
    #  };
    #};

    udev.packages = [
      # Used to set udev rules to access ST-LINK devices from probe-rs
      pkgs.openocd
    ];

    # Add a udev rule to connect CANable for updating its firmware
    udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE:="0666"
    '';
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Virtualization (Containers and VMs)
  virtualisation = {
    containers.enable = true;
    docker.enable = true;
  };

  # Enable Saleao Logic Analyzer support
  hardware.saleae-logic = {
    enable = true;
  };

  programs = {
    # Whether to configure zsh as an interactive shell.
    #   To enable zsh for a particular user, use the users.users.<name?>.shell option for that user.
    #   To enable zsh system-wide use the users.defaultUserShell option.
    zsh.enable = true;

    # Install firefox.
    firefox.enable = true;

    # Enable appimage-run wrapper script and binfmt registration
    appimage = {
      # Whether to enable appimage-run wrapper script for executing appimages on NixOS.
      enable = true;
      # Whether to enable binfmt registration to run appimages via appimage-run seamlessly.
      binfmt = true;
    };
  };

  # This option defines the default shell assigned to user accounts.
  # To enable zsh system-wide, use the users.defaultUserShell option.
  users.defaultUserShell = pkgs.zsh;

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # Replace with your username
    harrychen = {
      # You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      # initialPassword = "correcthorsebatterystaple";

      isNormalUser = true;
      description = "HarryChen";

      # https://nixos.wiki/wiki/SSH_public_key_authentication
      #openssh.authorizedKeys.keys = [
      #  # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      #];

      # Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      # Dialout group is used for USB serial coms: https://nixos.wiki/wiki/Serial_Console
      extraGroups = [
        "networkmanager"
        "wheel"
        "dialout"
      ];

      # To enable zsh for a particular user, use the users.users.<name?>.shell option for that user.
      shell = pkgs.zsh;
    };
  };

  environment = {
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      curl
      git
      vim
      wget

      # Install Input Method Panel GNOME Shell Extensions to provide the input method popup.
      gnomeExtensions.kimpanel
      # Install Gnome Tweaks for remapping CapsLock to Ctrl
      gnome-tweaks
    ];

    # A list of permissible login shells for user accounts.
    #   No need to mention /bin/sh here, it is placed into this list implicitly.
    #   replace pkgs.bashInteractive with pkgs.zsh
    shells = with pkgs; [ zsh ];

    # Set default editor as "vim"
    variables.EDITOR = "vim";
  };

  # Excluding some GNOME applications from the default install
  # https://nixos.wiki/wiki/GNOME
  environment.gnome.excludePackages = with pkgs; [
    gnome-photos
    gnome-tour
    gnome-clocks
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-weather
    gnome-calendar
    cheese # webcam tool
    epiphany # web browser
    geary # email reader
    totem # video player
    simple-scan # document scanner
    atomix # puzzle game
    hitori # sudoku game
    iagno # go game
    tali # poker game
    yelp
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11"; # Did you read the comment?
}
