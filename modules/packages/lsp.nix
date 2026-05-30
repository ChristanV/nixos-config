{ ... }:
{
  flake.nixosModules.lsp =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        terraform-ls
        yaml-language-server
        lua-language-server
        typescript-language-server
        bash-language-server
        jdt-language-server
        postgres-language-server
        dockerfile-language-server
        pyright
        gopls
        helm-ls
        nil
        nixd
      ];
    };
}
