{ config, lib, pkgs, ... }:
{

  users.users.klipper = {
    group = "klipper";
    extraGroups  = [ "dialout" ];
    isSystemUser = true;
  };

  users.groups.klipper = {};

  networking.firewall.allowedTCPPorts = [ 80 ];

  systemd.tmpfiles.settings = {
    "klipper" = {
      "/srv/printer_data" = {
        d = {
          group = "klipper";
          mode = "0755";
          user = "klipper";
        }; 
      };
    };
  };

  services.fluidd.enable = true;  

  systemd.services.klipper.serviceConfig = {
    ReadWritePaths = [ 
      "/srv/printer_data"
    ];
  };

  services.klipper = {
    configFile = "/srv/printer_data/config/printer.cfg";
    enable = true;
    configDir = "/srv/printer_data/config";
    mutableConfig = true;

    firmwares.mcu = {
      enable = true;
      configFile = ./mcu.config;
      serial = "/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0";
      enableKlipperFlash = true;
    };
  };

  services.moonraker = {
    enable = true;
    user = "klipper";
    stateDir = "/srv/printer_data";
    settings = {
      authorization = {
        trusted_clients = [
          "127.0.0.1"
          "100.64.0.0/16"
        ];
        
        cors_domains = [
          "https://klipper.mesh.loranjennings.com"
          "http://klipper.mesh.loranjennings.com"
        ];
      };
    };
  };

  services.mjpg-streamer.enable = true; #webcam support

  services.nginx.clientMaxBodySize = "1024m";
}
