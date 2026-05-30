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

        # Nix
        statix
        deadnix
        nixfmt

        # General
        pre-commit
        gitleaks
      ];
    };
}
