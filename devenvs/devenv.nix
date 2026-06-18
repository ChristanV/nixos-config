{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  name = "example";

  env.TEST = "test";

  packages = [
    pkgs.python312Packages.pip
  ];

  languages.python = {
    enable = true;
    package = pkgs.python312;
    venv.enable = true;
  };
}
