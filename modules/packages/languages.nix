{ ... }:
{
  flake.nixosModules.languages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Python
        python313
        python313Packages.pip
        virtualenv
        poetry

        # Node
        nodejs_24
        typescript
        yarn

        # Go
        go

        # Java
        jdk25

        # Lua
        lua
      ];
    };
}
