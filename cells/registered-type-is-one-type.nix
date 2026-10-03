# `registered-type-is-one-type` — C165, den-hoag-6orb8 U1. A type declared over a REGISTERED predicate
# (gen-algebra's encoder, a `basting` registry and its `stitch` constructor) is one type wherever it is
# built twice, and the registered term keys nothing:
#   1. the term carries no exact identity, so no key site keys on it, and a rule built from it has no
#      gen-dispatch override handle;
#   2. two `typedef`s over two constructions of one term are one type — `typeEq` true, and declared in
#      two modules they merge and the value `5` is admitted — while `50` is still refused by the term;
#   3. a different term (a wider bound) shares the type's mark, is decided `false`, and declared beside
#      it is refused by name; a bumped `revision` is decided `false` the same way;
#   4. two `bobbin` kinds over the twins are one kind under `kindEq`, and over the two terms two.
{
  asserts,
  genAlgebra,
  genDispatch,
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
  stitchR2 = genAlgebra.mkIntensional mint (basting // { revision = "r2"; }) "stitch";
  narrow = {
    lo = 1;
    hi = 9;
  };
  stitched = term: T.typedef "stitched" term;
  declaredTwice =
    a: b: v:
    let
      picks =
        (genMerge.evalModuleTree {
          modules = [
            { options.picks = genMerge.mkOption { type = a; }; }
            { options.picks = genMerge.mkOption { type = b; }; }
            { config.picks = v; }
          ];
        }).config.picks;
      r = builtins.tryEval (builtins.deepSeq picks picks);
    in
    if r.success then r.value else "REFUSED";
  bobbin =
    t:
    (genMerge.evalModuleTree {
      modules = [
        { options.schema = schema.mkSchemaOption { }; }
        { config.schema.bobbin.options.picks = genMerge.mkOption { type = t; }; }
      ];
    }).config.schema.bobbin;
  wide = stitch {
    lo = 1;
    hi = 10;
  };
in
{
  construct = [ "C165" ];
  check = asserts (
    # 1 — the term keys nothing
    !(genAlgebra.isExact (genAlgebra.identityOf (stitch narrow)))
    &&
      (genDispatch.fromFunction (
        genAlgebra.mkIntensional mint {
          revision = "r1";
          members.rule = _a: { picks, ... }: [ ];
        } "rule" { }
      )).identity == null
    # 2 — two constructions of one term are one type, and merge
    && T.typeEq (stitched (stitch narrow)) (stitched (stitch narrow))
    && declaredTwice (stitched (stitch narrow)) (stitched (stitch narrow)) 5 == 5
    && declaredTwice (stitched (stitch narrow)) (stitched (stitch narrow)) 50 == "REFUSED"
    # 3 — a different term or revision is another type: one mark, decided, and refused as a redeclaration
    && (stitched (stitch narrow)).__mint.minted == (stitched wide).__mint.minted
    && !(T.typeEq (stitched (stitch narrow)) (stitched wide))
    && declaredTwice (stitched (stitch narrow)) (stitched wide) 5 == "REFUSED"
    && !(T.typeEq (stitched (stitch narrow)) (stitched (stitchR2 narrow)))
    # 4 — and the kinds over them
    && schema.kindEq (bobbin (stitched (stitch narrow))) (bobbin (stitched (stitch narrow)))
    && !(schema.kindEq (bobbin (stitched (stitch narrow))) (bobbin (stitched wide)))
  );
}
