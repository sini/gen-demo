# `foreign-nested-role-carried` — C65, den-hoag-tn3qf (with yv161, 1jnzt, vl4l7). What a type
# CARRIES is read from where it says it carries it — its `nestedTypes` (or the module-set slot) —
# and a functor payload only for what it MERGES on. A foreign `bobbin` container states its element
# in `nestedTypes` beside a payload that is the element itself: its element now crosses into gen's
# `carries`, so redeclaring `bobbin port` as `bobbin int` refuses where it used to accept 70000, and
# gen-aspects' `aspectsRoot` reads as the element-carrying container it is. Before, both read
# `nestedTypes = { }` and the redeclaration merged with `port`'s check gone.
{
  asserts,
  genAspects,
  genMerge,
  lib,
}:
let
  bobbin =
    elemType:
    genMerge.mkOptionType {
      name = "bobbin";
      check = builtins.isAttrs;
      merge = _loc: defs: builtins.foldl' (acc: d: acc // d.value) { } defs;
      nestedTypes = { inherit elemType; };
      getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
      getSubModules = elemType.getSubModules or null;
      substSubModules = _m: bobbin elemType;
      functor = {
        name = "bobbin";
        payload = elemType;
        binOp = a: b: if a ? typeMerge && b ? functor then a.typeMerge b.functor else null;
        type = bobbin;
      };
    };
  spool =
    tys: v:
    let
      res = genMerge.evalModuleTree {
        modules = map (ty: { options.spool = genMerge.mkOption { type = ty; }; }) tys ++ [ { spool = v; } ];
      };
    in
    (builtins.tryEval (builtins.deepSeq res.config.spool res.config.spool)).success;
  root = genAspects.aspectsRoot { };
in
{
  construct = [ "C65" ];
  check = asserts (
    # the stated role crosses the boundary, and the redeclaration's drop is seen
    (bobbin lib.types.str).nestedTypes ? elemType
    && (bobbin lib.types.str) ? carries.element
    && !(spool [ (bobbin lib.types.port) (bobbin lib.types.int) ] { a = 70000; })
    # aspectsRoot is legible as a carrier
    && root.nestedTypes ? elemType
    && root ? carries.element
    # controls: the twin still merges, a gen container still states its element, a leaf states none
    && spool [ (bobbin lib.types.str) (bobbin lib.types.str) ] { a = "sateen"; }
    && (genMerge.types.attrsOf genMerge.types.str).nestedTypes ? elemType
    && !(genMerge.types.str.nestedTypes ? elemType)
  );
}
