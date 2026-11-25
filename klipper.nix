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

  services.fluidd = {
    enable = true;
    hostName = "klipper.mesh.loranjennings.com";
    nginx = {
      useACMEHost = "mesh.loranjennings.com";
      forceSSL = true;
      listen = [ { addr = "100.64.0.14"; port = 443; ssl = true; } ];
      locations."/webcam/" = {
        proxyPass = "http://127.0.0.1:5050/";
        extraConfig = ''
          proxy_buffering off;      # Prevents MJPEG stream freezes
          proxy_cache off;
          proxy_read_timeout 600s;
        '';
      };
    };
  };

  systemd.services.klipper.serviceConfig = {
    ReadWritePaths = [ 
      "/srv/printer_data"
    ];
  };

  services.klipper = {
    configFile = "/srv/printer_data/config/printer.cfg";
    enable = true;
    user = "klipper";
    group = "klipper";
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
    group = "klipper";
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
