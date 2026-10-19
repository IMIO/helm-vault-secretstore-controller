{ self, inputs, ... }:
{
  perSystem =
    { system, lib, ... }:
    {
      # customize nixpkgs instance
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
          inputs.imio.overlays.default
        ];
        config.allowUnfreePredicate =
          pkg:
          builtins.elem (lib.getName pkg) [
            "vault"
          ];
      };
    };
}
