{ ... }:
{
  flake.nixosModules.linters =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Python
        ruff

        # Terraform
        tflint
        tfsec
        terrascan
        terraform-docs
        tfupdate

        # Ansible
        ansible-lint

        # Lua
        stylua

        # Nix
        statix
        deadnix
        nixfmt

        # GitHub Actions
        actionlint

        # Shell
        shellcheck
        shfmt

        # General
        pre-commit
        gitleaks
      ];
    };
}
