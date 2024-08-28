{
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} ({
      config,
      lib,
      ...
    }: {
      # debug = true;
      systems = inputs.nixpkgs.lib.systems.flakeExposed;
      imports = [
        ./pre-commit.nix
      ];
      perSystem = {
        self',
        pkgs,
        config,
        system,
        ...
      }: let
        yarnModules = pkgs.mkYarnModules {
          pname = "yarn-modules";
          version = "1.0.0";
          yarnLock = ./yarn.lock;
          packageJSON = ./package.json;
        };
      in {
        devShells.default = pkgs.mkShell {
          inherit (config.pre-commit.devShell) shellHook;
          nativeBuildInputs = with pkgs; [
            nodejs
            just
            yarn
            yarnModules
          ];
        };
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "website";
          src = ./.;
          nativeBuildInputs = [yarnModules pkgs.nodejs];
          configurePhase = ''
            ln -s ${yarnModules}/node_modules node_modules
          '';
          buildPhase = ''
            npx  eleventy
          '';

          installPhase = ''
            cp -ar _site $out
          '';
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

    eleventy = {
      url = "github:11ty/eleventy?ref=v2.0.1";
      flake = false;
    };
  };
}
