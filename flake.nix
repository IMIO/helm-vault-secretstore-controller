{
  description = "Default Flake config at Imio";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-nix = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-linter = {
      url = "github:mic92/flake-linter";
      inputs.flake-parts.follows = "flake-parts";
    };
    imio = {
      url = "https://nexus.imio.be/repository/nix/imio-packages.tar.gz";
    };
    cachix-push = {
      url = "github:juspay/cachix-push/335e17ce32e784a9ddecb6f5bc9f7dabfbdb19fd";
    };
  };
  nixConfig = {
    extra-substituters = [ "https://imio.cachix.org" ];
    extra-trusted-public-keys = [ "imio.cachix.org-1:XRqcHQyUgbqq02ojDg0gdkEdHp63n5yINhBC55mPRKI=" ];
  };
  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        systems = [ "x86_64-linux" ];
        imports = [
          ./nix/check.nix
          ./nix/devshell.nix
          ./nix/fmt.nix
          ./nix/nixpkgs.nix
          ./nix/packages.nix
        ];
      }
    );
}
