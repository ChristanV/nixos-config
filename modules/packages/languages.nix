{ ... }:
{
  flake.nixosModules.languages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Python
        python312
        python312Packages.pip
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
