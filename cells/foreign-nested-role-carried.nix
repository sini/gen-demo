# `foreign-nested-role-carried` — C65, den-hoag-tn3qf (with yv161, 1jnzt, vl4l7). What a type
# CARRIES is read from where it says it carries it — its `nestedTypes` (or the module-set slot) —
# and a functor payload only for what it MERGES on. A foreign `bobbin` container states its element
# in `nestedTypes` beside a payload that is the element itself: its element now crosses into gen's
# `carries`, and gen-aspects' `aspectsRoot` reads as the element-carrying container it is. Before, both read
# `nestedTypes = { }`.
#
# A redeclaration is the meet (ADR-0039): it serves what every declaration alone serves. `bobbin`'s merge
# reads no element, so `bobbin port` alone serves `{ a = 70000; }`, and the pair serves it too.
# `bobbinRead`'s merge judges its element, so `bobbinRead port` alone refuses 70000, and the pair refuses it
# while serving `{ a = 80; }`: the drop under a nested role is seen (den-hoag-wsnn0 v1, which holds each
# declaration's own fold where a join renames an operand). The re-pin to the alone oracle is an
# orchestrator default, reversible (den-hoag-wsnn0, 2026-10-13); before it, the merge-blind pair was refused
# whole, 80 included.
{
  asserts,
  genAspects,
  genMerge,
  lib,
}:
let
  # one container spelling, its fold given: `blind` reads no element, `reading` judges each by its type
  bobbinWith =
    fold: elemType:
    genMerge.mkOptionType {
      name = "bobbin";
      check = builtins.isAttrs;
      merge = _loc: defs: fold elemType (builtins.foldl' (acc: d: acc // d.value) { } defs);
      nestedTypes = { inherit elemType; };
      getSubOptions = prefix: elemType.getSubOptions (prefix ++ [ "<name>" ]);
      getSubModules = elemType.getSubModules or null;
      substSubModules = _m: bobbinWith fold elemType;
      functor = {
        name = "bobbin";
        payload = elemType;
        binOp = a: b: if a ? typeMerge && b ? functor then a.typeMerge b.functor else null;
        type = bobbinWith fold;
      };
    };
  bobbin = bobbinWith (_elemType: v: v);
  bobbinRead = bobbinWith (
    elemType: v:
    builtins.mapAttrs (
      k: x: if elemType.check x then x else throw "bobbin: `${k}' is not of its element type"
    ) v
  );
  spool =
    tys: v:
    let
      res = genMerge.evalModuleTree { } (
        map (ty: { options.spool = genMerge.mkOption { type = ty; }; }) tys ++ [ { spool = v; } ]
      );
    in
    (builtins.tryEval (builtins.deepSeq res.config.spool res.config.spool)).success;
  root = genAspects.aspectsRoot { };
in
{
  construct = [ "foreign-nested-role-crosses-as-carried" ];
  check = asserts (
    # the stated role crosses the boundary
    (bobbin lib.types.str).nestedTypes ? elemType
    && (bobbin lib.types.str) ? carries.element
    # the merge-blind pair serves what each declaration alone serves
    && spool [ (bobbin lib.types.port) (bobbin lib.types.int) ] { a = 70000; }
    && spool [ (bobbin lib.types.port) ] { a = 70000; }
    # the element-judging pair: the drop is seen, and what both admit is served
    && !(spool [ (bobbinRead lib.types.port) (bobbinRead lib.types.int) ] { a = 70000; })
    && !(spool [ (bobbinRead lib.types.int) (bobbinRead lib.types.port) ] { a = 70000; })
    && !(spool [ (bobbinRead lib.types.port) ] { a = 70000; })
    && spool [ (bobbinRead lib.types.port) (bobbinRead lib.types.int) ] { a = 80; }
    # aspectsRoot is legible as a carrier
    && root.nestedTypes ? elemType
    && root ? carries.element
    # controls: the twin still merges, a gen container still states its element, a leaf states none
    && spool [ (bobbin lib.types.str) (bobbin lib.types.str) ] { a = "sateen"; }
    && (genMerge.types.attrsOf genMerge.types.str).nestedTypes ? elemType
    && !(genMerge.types.str.nestedTypes ? elemType)
  );
}
