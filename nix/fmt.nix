{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem = _: {
    treefmt = {
      projectRootFile = "flake.lock";
      flakeCheck = true;
      flakeFormatter = true;
      programs = {
        shellcheck.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        nixfmt.enable = true;
      };
      settings.formatter = {
        shellcheck.options = [
          "--shell=bash"
          "--check-sourced"
        ];
      };
    };
  };
}
