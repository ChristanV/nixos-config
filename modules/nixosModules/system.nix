_: {
  flake.nixosModules.system = _: {
    nixpkgs.hostPlatform = "x86_64-linux";
  };
}
