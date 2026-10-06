# `type-copy-refused-by-name` — C168, den-hoag-6orb8 U1b. A type's identity is a claim about the
# record its constructor completed. A `//` that replaces the `verify` of a `spool` type keeps the
# mark while admitting every value, so comparing it with the type it was copied from is refused by
# name, never answered `true`; declared as an option it is still served, and declaring the true type
# beside it still refuses "x". Types a module declares are completed at gen-merge's boundary, so they
# decide as before. The price, stated: a description-only `//` is a copy too, and is refused the same
# way at `typeEq`.
{
  asserts,
  genMerge,
}:
let
  T = genMerge.types;
  spool = T.int;
  slack = spool // {
    verify = _: null;
  };
  decides = e: (builtins.tryEval (builtins.deepSeq e e)).success;
  picks =
    tys: v:
    let
      p =
        (genMerge.evalModuleTree { } (
          map (t: { options.picks = genMerge.mkOption { type = t; }; }) tys ++ [ { picks = v; } ]
        )).config.picks;
      r = builtins.tryEval (builtins.deepSeq p p);
    in
    if r.success then r.value else "REFUSED";
in
{
  construct = [ "copy-of-a-type-is-refused-by-name" ];
  check = asserts (
    !(decides (T.typeEq spool slack))
    && picks [ slack ] "x" == "x"
    && picks [ spool slack ] "x" == "REFUSED"
    && picks [ slack spool ] "x" == "REFUSED"
    && T.typeEq spool T.int
    && !(T.typeEq spool T.str)
    && !(decides (T.typeEq T.str (T.str // { description = "a label"; })))
  );
}
