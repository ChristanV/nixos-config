{ ... }:
{
  flake.nixosModules.wslPackages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        monkeysphere
        redpanda-client
        stdenv.cc.cc.lib # libstdc++ for python numpy
        zlib
        xclip
        cacert
        btop
      ];
    };
}
