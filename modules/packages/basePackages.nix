{ self, ... }:
{
  flake.nixosModules.basePackages = {
    imports = [
      self.nixosModules.unstablePkgs
      self.nixosModules.cli
      self.nixosModules.editors
      self.nixosModules.languages
      self.nixosModules.lsp
      self.nixosModules.linters
    ];
  };
}
