{
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({config, ...}: {
      # debug = true;
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      imports = [
        ./pre-commit.nix
      ];
      _module.args = {
        username = "kdanisme";
        lock = with builtins; (fromJSON (readFile ./flake.lock));
      };
      perSystem = {
        pkgs,
        config,
        system,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          inherit (config.pre-commit.devShell) shellHook;
          nativeBuildInputs = with pkgs; [
            nodejs_21
          ];
        };
      };
    });

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
