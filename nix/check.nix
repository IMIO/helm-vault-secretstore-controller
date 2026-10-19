{ inputs, ... }:
{
  imports = [ inputs.pre-commit-nix.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      pre-commit = {
        settings = {
          hooks = {
            nil.enable = true;
            deadnix.enable = true;
            statix.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;
            markdownlint = {
              enable = true;
              settings.configuration = {
                MD013 = {
                  line_length = 120;
                };
              };
            };
            treefmt.enable = true;

            helm-lint = {
              enable = true;
              name = "helm-lint";
              description = "helm lint the chart";
              files = "^(Chart\\.yaml|values\\.yaml|templates/.*)$";
              language = "system";
              pass_filenames = false;
              entry = toString (
                pkgs.writeShellScript "precommit-helm-lint" ''
                  set -euo pipefail
                  ${pkgs.kubernetes-helm}/bin/helm lint --set clusterName=test --set vaultAddr=https://vault.example.invalid .
                ''
              );
            };
          };
          settings = {
            markdownlint.config = {
              MD013 = {
                line_length = 120;
              };
            };
          };
        };
      };
    };
}
