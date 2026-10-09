# `sibling-stating-no-module-set-threads` — nixpkgs' `coercedTo` from a leaf whose override reads its
# stock rebuild (`m: null`) as a type, to a gen submodule (`shuttle`). The leaf is a sibling of the
# threaded element and states no module set, so nixpkgs' `fixupOptionType` never calls its
# `substSubModules`, and gen-merge no longer hands it the marker either: the container threads and the
# value is nixpkgs', a module definition reading `twill` and an `int` coerced to `coerced`. gen-merge
# used to call the override, which aborted uncatchably on `null // { … }` (den-hoag-87nvk). The
# control is the same type over nixpkgs' own submodule in nixpkgs' engine, which reads the same two.
{
  asserts,
  genMerge,
  lib,
}:
let
  readsNull = a: a // { substSubModules = m: readsNull (a.substSubModules m); };
  holder = lib.types.coercedTo (readsNull lib.types.int) (_: {
    weft = "coerced";
  });
  weft = m: {
    options.weft = m.mkOption {
      type = m.types.str;
      default = "plain";
    };
  };
  shuttle = genMerge.types.submodule (weft genMerge);
  twin = lib.types.submodule (weft lib);
  reads =
    evalModules: m: type: v:
    (evalModules [
      { options.seam = m.mkOption { type = holder type; }; }
      { seam = v; }
    ]).config.seam.weft;
  gen = reads (genMerge.evalModuleTree { }) genMerge shuttle;
  nixpkgs = reads (modules: lib.evalModules { inherit modules; }) lib twin;
in
{
  construct = [ "a-sibling-stating-no-module-set-is-not-handed-the-marker" ];
  check = asserts (
    gen { weft = "twill"; } == "twill"
    && gen 3 == "coerced"
    && nixpkgs { weft = "twill"; } == "twill"
    && nixpkgs 3 == "coerced"
  );
}
