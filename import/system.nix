{ config, pkgs, lib, ... }:

let
  # Client configuration
  cfg = config.programs.shadow-client;

  # A set of utilities
  utilities = import ../utilities { inherit lib pkgs; };

  # Declare the package with the appropriate configuration
  shadow-package = pkgs.callPackage ../default.nix {
    shadowChannel = cfg.channel;
    enableDiagnostics = cfg.enableDiagnostics;
    desktopLauncher = cfg.enableDesktopLauncher;
  };

  # Drirc file
  drirc = utilities.files.drirc;
in {
  # Import the configuration
  imports = [ ../config.nix ../x-session ../systemd-session ];

  # By default, if you import this file, the Shadow app will be installed
  programs.shadow-client.enable = lib.mkDefault true;

  # Enables
  environment = lib.mkIf cfg.enable {
    # Install Shadow wrapper
    systemPackages = with pkgs; [ shadow-package libva-utils libva ];

    # Add GPU fixes
    etc.drirc.source = lib.mkIf (cfg.enableGpuFix) drirc;

    # Force VA Driver
    variables.LIBVA_DRIVER_NAME = lib.mkIf (cfg.forceDriver != null) [ cfg.forceDriver ];
  };
}
