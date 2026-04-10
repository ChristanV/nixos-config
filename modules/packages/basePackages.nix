{ inputs, ... }:
{
  flake.nixosModules.basePackages =
    { pkgs, ... }:
    let
      unstable = import inputs.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
        inherit (pkgs) config;
      };
    in
    {
      environment.systemPackages = with pkgs; [
        # Security
        clamav
        unstable._1password-cli
        tailscale
        gnome-keyring
        libsecret
        libxcrypt

        # Core Packages
        neovim
        vimPlugins.packer-nvim
        gnumake
        busybox
        wget
        stern
        jq
        yq-go
        kubernetes-helm
        openssl
        go-task
        virtualenv
        kubectl
        kubectx
        kubelogin
        git
        postgresql
        eksctl
        lazygit
        fd
        ripgrep
        zoxide
        flyctl
        sops
        gnupg
        k9s
        ssm-session-manager-plugin
        (azure-cli.withExtensions [
          pkgs.azure-cli-extensions.bastion
          pkgs.azure-cli-extensions.ssh
        ])
        awscli2
        docker_28
        docker-compose
        zsh
        zsh-fzf-tab
        steampipe
        fzf
        starship
        glow
        nvidia-container-toolkit
        btop-cuda
        plantuml
        graphviz
        fastfetch
        ethtool
        kustomize
        zip
        terraform
        terragrunt
        python313
        python312Packages.pip
        python312Packages.ansible-core
        poetry
        go
        nodejs_24
        typescript
        lua
        yarn
        kind
        k3s
        jdk25
        chromedriver
        unstable.trunk-io
        gemini-cli
        github-copilot-cli
        gh
        direnv
        devenv
        xclip

        # LSP's, Linters and checkers
        terraform-ls
        tflint
        yaml-language-server
        ansible-lint
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
        statix
        deadnix
        tfsec
        terrascan
        pre-commit
        nixfmt
        gitleaks
        terraform-docs
        tfupdate
      ];
    };
}
