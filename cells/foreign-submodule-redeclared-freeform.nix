# `foreign-submodule-redeclared-freeform` — C122, den-hoag-a0c4z. A stock nixpkgs submodule option is
# redeclared in two modules, its `freeformType` stated in one half and the definition it absorbs in
# the other (the stock NixOS `systemd.network` shape). nixpkgs' submodule states `nestedTypes` as an
# output of evaluating the type's own module set with no definitions, and alone the defining half
# has neither the key nor the freeform, so a walk forcing it refused "option does not exist".
# gen-merge now never forces it, and the option resolves to nixpkgs' value. The control: a key no
# operand declares and no freeformType absorbs still refuses, on both engines.
{
  asserts,
  genMerge,
  lib,
}:
let
  t = lib.types;
  served =
    eval: mods:
    let
      r = builtins.tryEval (
        let
          v = (eval mods).config.loom;
        in
        builtins.deepSeq v v
      );
    in
    if r.success then r.value else null;
  gen = served (modules: genMerge.evalModuleTree { } modules);
  ref = served (modules: lib.evalModules { inherit modules; });
  halves = [
    {
      options.loom = lib.mkOption {
        type = t.submodule { config.warp = 2; };
        default = { };
      };
    }
    { options.loom = lib.mkOption { type = t.submodule { freeformType = t.attrsOf t.int; }; }; }
  ];
  undeclared = [
    {
      options.loom = lib.mkOption {
        type = t.submodule { config.weft = 2; };
        default = { };
      };
    }
    {
      options.loom = lib.mkOption {
        type = t.submodule { options.warp = lib.mkOption { type = t.int; }; };
      };
    }
  ];
in
{
  construct = [ "redeclared-nixpkgs-submodule-completes-its-halves" ];
  check = asserts (
    gen halves == {
      warp = 2;
    }
    && gen halves == ref halves
    && gen undeclared == null
    && ref undeclared == null
  );
}
