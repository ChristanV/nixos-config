_: {
  flake.nixosModules.cli =
    { pkgs, unstable, ... }:
    {
      environment.systemPackages = with pkgs; [
        # Security
        unstable._1password-cli
        libsecret
        libxcrypt
        sops
        gnupg
        monkeysphere

        # Core
        gnumake
        busybox
        wget
        jq
        yq-go
        openssl
        go-task
        fd
        ripgrep
        zoxide
        fzf
        zsh-fzf-tab
        starship
        glow
        fastfetch
        ethtool
        zip
        xclip
        zellij
        yazi
        btop-cuda
        plantuml
        graphviz
        devenv

        # Git
        git
        lazygit
        pinact
        gh
        unstable.trunk-io

        # AI
        github-copilot-cli
        unstable.claude-code

        # Kubernetes
        kubernetes
        kubectl
        kubectx
        kubelogin
        kubernetes-helm
        kustomize
        stern
        k9s
        kind
        sonobuoy

        # Cloud
        #(azure-cli.withExtensions [
        #  pkgs.azure-cli-extensions.bastion
        #  pkgs.azure-cli-extensions.ssh
        #])
        awscli2
        flyctl
        eksctl
        ssm-session-manager-plugin
        steampipe

        # Containers
        docker_29
        docker-compose
        lazydocker
        nvidia-container-toolkit
        regctl

        # Infra
        terraform
        terragrunt

        # Database
        postgresql

        # Misc
        chromedriver
        gcc

        # Data
        snowflake-cli
        # redpanda-client
        rsync
        snowsql
      ];
    };
}
