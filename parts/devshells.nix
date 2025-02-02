{inputs, ...}: {
  perSystem = {
    inputs',
    config,
    lib,
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      packages = [
        pkgs.alejandra
        pkgs.cachix
        pkgs.jq
        pkgs.just
        pkgs.lua-language-server
        pkgs.markdownlint-cli
        pkgs.nixd
        pkgs.prettierd
      ];

      # Set up pre-commit hooks when user enters the shell.
      shellHook = let
        recipes = {
          fmt = {
            text = ''${lib.getExe config.treefmt.build.wrapper}'';
            doc = "Format all files in the repository";
          };
        };
        commonJustfile = pkgs.writeTextFile {
          name = "justfile.incl";
          text =
            lib.concatStringsSep "\n"
            (lib.mapAttrsToList (name: recipe: ''
                ${lib.concatStringsSep "\n" (builtins.map (tag: "[${tag}]") (recipe.tags or []))}
                [group('devshell')]
                [doc("${recipe.doc}")]
                ${name}:
                    ${recipe.text}
              '')
              recipes);
        };
      in ''
        ${config.pre-commit.installationScript}
        ln -sf ${builtins.toString commonJustfile} ./.justfile.incl
      '';

      # Tell Direnv to shut up.
      DIRENV_LOG_FORMAT = "";
    };
  };
}
