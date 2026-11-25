# ============================================================
# octoprint.nix — Ocotoprint Basic Module.
# ============================================================

{ config, lib, pkgs, ... }:

{
  services.octoprint = {
    enable = true;
    host = "100.64.0.14";
    port = 6899;
  };
}
