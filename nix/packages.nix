{ inputs, ... }:
{
  imports = [ inputs.cachix-push.flakeModule ];
  perSystem =
    { pkgs, ... }:
    {
      packages = { inherit (pkgs) kubernetes-helm; };

      cachix-push = {
        cacheName = "imio";
      };
    };

  flake.overlays.default = _final: _prev: { };
}
