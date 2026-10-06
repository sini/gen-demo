# `composite-types-are-minted` — C202, den-hoag-6orb8 U2. gen-merge's composites carry an identity
# built per component, so a composite is one type wherever it is built:
#   1. `listOf int` carries a mark, is one type built twice, and is itself after transport through an
#      `anything` slot;
#   2. `listOf` over two constructions of one registered term (a `basting` registry, its `stitch`
#      constructor) is one type, directly and transported, and two `bobbin` kinds carrying it are one
#      kind; the registered term never enters the mark (a wider bound shares it and is decided `false`);
#   3. a user's own parametric type, `spoolOf`, a `deriveType` over `listOf`, is one type built twice
#      and transported, admits `[ 1 2 ]` and refuses a string element, and `spoolOf str` is another;
#   4. nixpkgs-parity merges stand: `listOf int` declared twice serves `[ 1 ]`, and two submodules
#      declaring `a` and `b` union to both.
#   5. the stated cost: two constructions of `listOf int` defined in one `anything` slot are refused by
#      name, where one value defined twice folds.
{
  asserts,
  genAlgebra,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  T = genMerge.types;
  mint = inputs.gen.lib.substrate.identity.hashIdentity;
  basting = {
    revision = "r1";
    members.stitch = a: v: builtins.isInt v && v >= a.lo && v <= a.hi;
  };
  stitch = genAlgebra.mkIntensional mint basting "stitch";
  narrow = {
    lo = 1;
    hi = 9;
  };
  wide = {
    lo = 1;
    hi = 10;
  };
  stitched = args: T.listOf (T.typedef "stitched" (stitch args));
  spoolOf = e: genMerge.deriveType { } "spoolOf" (T.listOf e);
  value =
    e:
    let
      r = builtins.tryEval (builtins.deepSeq e e);
    in
    if r.success then r.value else "REFUSED";
  eval =
    tys: vs:
    value
      (genMerge.evalModuleTree { } (
        map (t: { options.picks = genMerge.mkOption { type = t; }; }) tys ++ map (v: { picks = v; }) vs
      )).config.picks;
  carried =
    v:
    (genMerge.evalModuleTree { } ([
      { options.k = genMerge.mkOption { type = T.anything; }; }
      { config.k = v; }
    ])).config.k;
  # the slot's value is a type record, so only its description is forced
  carriedTwice =
    a: b:
    value
      (genMerge.evalModuleTree { } ([
        { options.k = genMerge.mkOption { type = T.anything; }; }
        { config.k = a; }
        { config.k = b; }
      ])).config.k.description;
  bobbin =
    t:
    (genMerge.evalModuleTree { } ([
      { options.schema = schema.mkSchemaOption { }; }
      { config.schema.bobbin.options.picks = genMerge.mkOption { type = t; }; }
    ])).config.schema.bobbin;
  intList = T.listOf T.int;
in
{
  construct = [ "C202" ];
  check = asserts (
    # 1
    (T.listOf T.int).__mint ? minted
    && T.typeEq (T.listOf T.int) (T.listOf T.int)
    && T.typeEq (T.listOf T.int) (carried (T.listOf T.int))
    # 2
    && T.typeEq (stitched narrow) (stitched narrow)
    && T.typeEq (stitched narrow) (carried (stitched narrow))
    && schema.kindEq (bobbin (stitched narrow)) (bobbin (stitched narrow))
    && schema.kindEq (bobbin (stitched narrow)) (carried (bobbin (stitched narrow)))
    && (stitched narrow).__mint.minted == (stitched wide).__mint.minted
    && !(T.typeEq (stitched narrow) (stitched wide))
    # 3
    && T.typeEq (spoolOf T.int) (spoolOf T.int)
    && T.typeEq (spoolOf T.int) (carried (spoolOf T.int))
    && !(T.typeEq (spoolOf T.int) (spoolOf T.str))
    &&
      eval
        [ (spoolOf T.int) ]
        [
          [
            1
            2
          ]
        ] == [
        1
        2
      ]
    &&
      eval
        [ (spoolOf T.int) ]
        [
          [
            1
            "x"
          ]
        ] == "REFUSED"
    # 4
    && eval [ (T.listOf T.int) (T.listOf T.int) ] [ [ 1 ] ] == [ 1 ]
    &&
      eval
        [
          (T.submodule {
            options.a = genMerge.mkOption {
              type = T.int;
              default = 1;
            };
          })
          (T.submodule {
            options.b = genMerge.mkOption {
              type = T.int;
              default = 2;
            };
          })
        ]
        [ ] == {
        a = 1;
        b = 2;
      }
    # 5
    && carriedTwice (T.listOf T.int) (T.listOf T.int) == "REFUSED"
    && carriedTwice intList intList == "list of signed integer"
  );
}
