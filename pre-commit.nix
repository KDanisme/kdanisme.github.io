{inputs, ...}: {
  imports = [
    inputs.flake-root.flakeModule
    inputs.treefmt-nix.flakeModule
    inputs.pre-commit-hooks.flakeModule
  ];
  perSystem = {
    pkgs,
    config,
    self',
    ...
  }: {
    pre-commit.settings.hooks.treefmt.enable = true;
    treefmt.config = {
      inherit (config.flake-root) projectRootFile;
      flakeCheck = false;
      programs = {
        alejandra.enable = true;
        prettier.enable = true;
      };
    };
  };
}
