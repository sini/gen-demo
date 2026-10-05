# `step-free-wrapper-container` — C192, den-hoag-t1j4z Build 1 (ADR-0039, the serve half). A gen
# container of nested trees under a nixpkgs wrapper that adds no step (`uniq`, `coercedTo`) sits at
# the walk's own root, where gen-merge walks it as the root is and serves nixpkgs' value; it once
# refused the shape by name (S1 class (a)). The inner containers are gen-merge's own: a nixpkgs
# container under the wrapper is captured by its threaded split and never reaches that arm.
# `o.bar` throws and is never read: keying `o.foo` forces no sibling.

{
  asserts,
  genMerge,
  lib,
}:

let
  t = genMerge.types;
  sub = t.submodule { options.x = genMerge.mkOption { type = t.int; }; };
  value =
    type: defs:
    (genMerge.evalModuleTree { } (
      [ { options.o = genMerge.mkOption { inherit type; }; } ] ++ map (d: { config.o = d; }) defs
    )).config.o;
in
{
  construct = [ "C192" ];
  check = asserts (
    (value (lib.types.uniq (t.lazyAttrsOf (t.attrsOf sub))) [
      {
        foo.a.x = 1;
        bar = throw "sibling read";
      }
    ]).foo.a.x == 1
    # nixpkgs' order: the later module's definition first
    &&
      value (lib.types.coercedTo lib.types.str (_: [ { x = 2; } ]) (t.listOf sub)) [
        [ { x = 1; } ]
        "s"
      ] == [
        { x = 2; }
        { x = 1; }
      ]
  );
}
