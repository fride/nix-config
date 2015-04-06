# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

   security.initialRootPassword="foobar";


   nix.binaryCaches = [ http://cache.nixos.org 
http://hydra.nixos.org ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.extraEntries= ''
	menuentry 'Windows 8 (loader) (auf /dev/sda1)' --class windows --class os $menuentry_id_option 'osprober-chain-A0324E9E324E78F4' {
		insmod part_msdos
		insmod ntfs
		set root='hd0,msdos1'
		if [ x$feature_platform_search_hint = xy ]; then
	  		search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1 --hint-baremetal=ahci0,msdos1  A0324E9E324E78F4
		else
	  		search --no-floppy --fs-uuid --set=root A0324E9E324E78F4
		fi
		drivemap -s (hd0) 'hd0,msdos1' 
		chainloader +1
	}
  '';  


    # nixpkgs.config.allowUnfree = true; # :((( this is because of btsync
  # networking.hostName = "nixos"; # Define your hostname.
  networking.hostId = "dd3b0ca0";
  # networking.wireless.enable = true;  # Enables wireless.


  #
  # Audio, from https://nixos.org/wiki/Audio_HOWTO
  #
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudio.override { 
	jackaudioSupport = true; 
  };

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "lat9w-16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
    environment.systemPackages = with pkgs; [
      wget
      emacs zsh joe git nodejs-unstable ponysay bittorrentSync evilvte mu powertop
      file inetutils lftp offlineimap unzip xlibs.xev duply rsync      
      
      # essentials
      tmux htop wget ponysay psmisc gptfdisk gnupg

      # build essentials
      binutils gcc gnumake pkgconfig python ruby nodejs
  

      # desktop components
      dmenu xlibs.xbacklight xscreensaver unclutter compton
      networkmanagerapplet volumeicon pavucontrol feh
      xlibs.xrandr liberation_ttf pavucontrol
      libnotify gnome3.gnome_themes_standard
      gnome3.gnome_icon_theme gnome3.gsettings_desktop_schemas
      acpi dunst jq 
      gtk # To get GTK+'s themes
      gnome.gnomeicontheme # more icons
      hicolor_icon_theme # icons for thunar
      shared_mime_info



      # desktop apps
      firefox-bin evince mplayer chromium thunderbird vlc  
      
      zathura # pdf viewer

     #Java, Scala and friend
     sbt 
#	openjdk8 
#     oraclejdk8 # Im to supid for this
  ];

   environment.shells = [ "/run/current-system/sw/bin/zsh" ];
   environment.variables.EDITOR = pkgs.lib.mkForce "joe";
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
    services.openssh.enable = false;
    programs.ssh.startAgent = false;


    services.autofs.enable = true ;
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";


    
	nixpkgs.config = {
		allowUnfree = true;
		chromium.enablePepperFlash = true;
		chromium.enablePepperPDF = true;
#		packageOverrides = pkgs: {
#			jre = pkgs.oraclejre8;
#			jdk = pkgs.oraclejdk8;
#		};
	};

    services.xserver = {
      enable = true;
      layout = "us";
      desktopManager.xterm.enable = false;
      windowManager.xmonad.enable = true;
      windowManager.xmonad.enableContribAndExtras = true;
      windowManager.xmonad.extraPackages = haskellPackages: [
        haskellPackages.taffybar
      ];
      windowManager.default = "none";
      displayManager = {
          slim = {
	       enable = true;
	       defaultUser = "jnfrd";
	  };
      };
      xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";      
      startGnuPGAgent = true;
    };
  

    services.udisks2.enable = true;
    services.gnome3.at-spi2-core.enable = true;
    
    environment.variables.GTK_DATA_PREFIX = "${pkgs.gnome3.gnome_themes_standard}";
  

    environment.etc."gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Adwaita
      gtk-icon-theme-name=gnome
      gtk-font-name=Liberation Sans 15
      gtk-cursor-theme-name=Adwaita
      gtk-cursor-theme-size=0
      gtk-toolbar-style=GTK_TOOLBAR_BOTH
      gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
      gtk-button-images=1
      gtk-menu-images=1
      gtk-enable-event-sounds=1
      gtk-enable-input-feedback-sounds=1
      gtk-xft-antialias=1
      gtk-xft-hinting=1
      gtk-xft-hintstyle=hintslight
      gtk-xft-rgba=rgb
    '';

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.kdm.enable = true;
  # services.xserver.desktopManager.kde4.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.extraUsers.guest = {
  #   isNormalUser = true;
  #   uid = 1000;
  # };

  #
  # Setup the emacs deamon!
  #
  systemd.user.services.emacs = {
   	description = "Emacs Daemon";
   	environment.GTK_DATA_PREFIX = config.system.path;
   	environment.SSH_AUTH_SOCK = "%t/ssh-agent";
   	environment.GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
   	serviceConfig = {
    		 Type = "forking";
     		ExecStart = "${pkgs.emacs}/bin/emacs --daemon";
     		ExecStop = "${pkgs.emacs}/bin/emacsclient --eval (kill-emacs)";
     		Restart = "always";
   	};
   	wantedBy = [ "default.target" ];
  };
 
  systemd.services.emacs.enable = true;


  users.mutableUsers = true;
  users.extraUsers.jnfrd = {
      name = "jnfrd";
      group = "users";
      extraGroups = [ "wheel" "disk" "audio" "video" "networkmanager" "systemd-journal" ];
      uid = 1000;
      createHome = true;
      home = "/home/jnfrd";
      shell = "/run/current-system/sw/bin/zsh";
    };

}
