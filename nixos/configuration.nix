# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
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
    ./hardware-configuration.nix
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

  # Set your hostname
  networking.hostName = "nixos";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Taipei";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-chewing
      fcitx5-gtk
    ];
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji-blob-bin
      source-code-pro
    ];
    fontconfig = {
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
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
  # services.xserver.libinput.enable = true;

  # This option defines the default shell assigned to user accounts.
  # To enable zsh system-wide, use the users.defaultUserShell option.
  users.defaultUserShell = pkgs.zsh;

  # Configure your system-wide user settings (groups, etc), add more users as needed.
  users.users = {
    # Replace with your username
    baffen227 = {
      # You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      # initialPassword = "correcthorsebatterystaple";

      isNormalUser = true;
      description = "baffen227";

      # https://nixos.wiki/wiki/SSH_public_key_authentication
      #openssh.authorizedKeys.keys = [
      #  # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      #];

      # Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
      extraGroups = [
        "networkmanager"
        "wheel"
      ];

      # To enable zsh for a particular user, use the users.users.<name?>.shell option for that user.
      shell = pkgs.zsh;
    };
  };

  # Whether to configure zsh as an interactive shell.
  #   To enable zsh for a particular user, use the users.users.<name?>.shell option for that user.
  #   To enable zsh system-wide use the users.defaultUserShell option.
  programs.zsh.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Enable appimage-run wrapper script and binfmt registration
  programs.appimage = {
    # Whether to enable appimage-run wrapper script for executing appimages on NixOS.
    enable = true;
    # Whether to enable binfmt registration to run appimages via appimage-run seamlessly.
    binfmt = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    git

    # Install Input Method Panel GNOME Shell Extensions to provide the input method popup.
    gnomeExtensions.kimpanel

    # Install Gnome Tweaks for remapping CapsLock to Ctrl
    gnome.gnome-tweaks

    vim
    wget
  ];

  # A list of permissible login shells for user accounts.
  #   No need to mention /bin/sh here, it is placed into this list implicitly.
  #   replace pkgs.bashInteractive with pkgs.zsh
  environment.shells = with pkgs; [ zsh ];

  # Set default editor as "vim" 
  environment.variables.EDITOR = "vim";

  # Excluding some GNOME applications from the default install
  # https://nixos.wiki/wiki/GNOME
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      yelp
    ])
    ++ (with pkgs.gnome; [
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
    ]);

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  #services.openssh = {
  #  enable = true;
  #  settings = {
  #    # Opinionated: forbid root login through SSH.
  #    PermitRootLogin = "no";
  #    # Opinionated: use keys only.
  #    # Remove if you want to SSH using passwords
  #    PasswordAuthentication = false;
  #  };
  #};

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
