# `module-path-string` — C43, den-hoag-submodule-admits-path-string-uetyh. A nesting type admits
# what nixpkgs admits as a module: a string naming a module file is the module under `either
# (submodule M) str`, so the union reads `{ key = "sateen"; }` where it used to answer the string,
# and `lint` collects that string as the engine imports it, where it used to drop it with no
# finding.
#
# C43 — den-hoag-submodule-admits-path-string-uetyh: a nesting type admits
# what nixpkgs admits as a module. A STRING naming a module file is the MODULE under
# `either (submodule M) str`, as `lib.types.submodule`'s `path.check` reads it, where
# the union used to answer the string; and `lint` collects that string as the
# engine imports it, where it used to drop it with no finding.
{ asserts, genMerge }:
{
  construct = [ "C43" ];
  check = asserts (
    let
      at =
        type: def:
        (genMerge.evalModuleTree {
          modules = [
            { options.seam = genMerge.mkOption { inherit type; }; }
            { config.seam = def; }
          ];
        }).config.seam;
      keyed = genMerge.types.submodule {
        options.key = genMerge.mkOption {
          type = genMerge.types.str;
          default = "none";
        };
      };
      # Files in the flake source, named by STRING: `toString` of a path is the
      # store-path string `lib.types.submodule`'s `path.check` admits. Never
      # `builtins.toFile`, which CI's read-only `--no-build` eval cannot import.
      spool = toString ../fixtures/module-path-string/spool.nix;
      lintee = toString ../fixtures/module-path-string/lintee.nix;
    in
    at (genMerge.types.either keyed genMerge.types.str) spool == {
      key = "sateen";
    }
    && builtins.length (genMerge.lint { modules = [ lintee ]; }) == 1
  );
}
