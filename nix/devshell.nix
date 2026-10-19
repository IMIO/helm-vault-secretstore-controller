{ inputs, ... }:
{
  imports = [ inputs.devshell.flakeModule ];
  perSystem =
    { config, pkgs, ... }:
    {
      devshells.default = {
        packages = [
          pkgs.git
          pkgs.jq
          pkgs.kubernetes-helm
          pkgs.kind
          pkgs.kubectl
        ];
        devshell.startup.pre-commit.text = config.pre-commit.installationScript;
        commands = [
          {
            name = "fmt";
            help = "Format code";
            command = "nix fmt";
            category = "check";
          }
          {
            name = "check";
            help = "Run all checks";
            command = "nix flake -L check -v";
            category = "check";
          }
          {
            name = "lint";
            help = "Lint code";
            command = "pre-commit run --all-files";
            category = "check";
          }
          {
            name = "test-install";
            help = "helm install the chart into a throwaway kind cluster, then tear it down";
            command = ''
              set -euo pipefail
              kind create cluster --name vault-secretstore-controller-test
              trap 'kind delete cluster --name vault-secretstore-controller-test' EXIT
              helm install test . --set clusterName=test --set vaultAddr=https://vault.example.invalid --wait --timeout 60s
            '';
            category = "check";
          }
        ];
      };
    };
}
