# `configuration-in-options-refused-by-name` — den-hoag-eb4kj. An evaluated configuration placed
# where an option declaration belongs (nixpkgs modules.sh `options-type-error-configuration.nix`:
# `options.result = evalModules { … }`) is refused by name, catchable, as nixpkgs' `evalModules`
# refuses it. gen-merge used to walk into the configuration as though it were a group of
# declarations, forcing its values: here an option default nothing reads, which aborts when forced,
# so the walk aborted uncatchably where nixpkgs refuses without reading it. The twin declaring the
# same option with `mkOption` reads as nixpkgs reads it, so a door refusing every declaration cannot
# pass.
{
  asserts,
  genMerge,
  lib,
}:
let
  attempt = r: builtins.tryEval (builtins.deepSeq r.config.shuttle r.config.shuttle);
  gen = decl: attempt (genMerge.evalModuleTree { } [ { options.shuttle = decl genMerge; } ]);
  ref = decl: attempt (lib.evalModules { modules = [ { options.shuttle = decl lib; } ]; });
  loom = L: [ { options.weft = L.mkOption { default = abort "weft is never read"; }; } ];
  evaluated =
    L:
    if L ? evalModuleTree then L.evalModuleTree { } (loom L) else L.evalModules { modules = loom L; };
  declared = L: L.mkOption { default = "s"; };
in
{
  construct = [ "an-evaluated-configuration-in-options-is-refused-by-name" ];
  check = asserts (
    !(gen evaluated).success
    && !(ref evaluated).success
    && (ref declared).value == "s"
    && (gen declared).value == (ref declared).value
  );
}
