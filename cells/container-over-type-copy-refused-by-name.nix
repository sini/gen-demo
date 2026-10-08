# `container-over-type-copy-refused-by-name` — den-hoag-6d5r3. A container's identity is minted over
# its members' identities, so a container over a `//` copy of a type can carry no more identity than
# the copy does. `spool // { verify = _: null; }` keeps `spool`'s mark while admitting every value, and
# its own identity is refused (`type-copy-refused-by-name`); a `listOf`, `attrsOf` or `nullOr` over it,
# raw or re-completed through `types.defineType`, and a `listOf` nested over that, is refused the same
# way and never answers `listOf spool`'s identity, which each of them carried. Over `spool` itself every
# container keeps its identity, and the values served are unchanged.
{
  asserts,
  genMerge,
  inputs,
}:
let
  inherit (inputs.gen.lib.modules.types) idOf;
  T = genMerge.types;
  spool = T.int;
  slack = spool // {
    verify = _: null;
  };
  refused = e: !(builtins.tryEval (builtins.deepSeq e e)).success;
  containers = [
    T.listOf
    T.attrsOf
    T.nullOr
    (m: T.listOf (T.listOf m))
  ];
  hasNoIdentity =
    c:
    refused (idOf (c slack))
    && refused (idOf (c (T.defineType slack)))
    && !(refused (idOf (c spool)))
    && idOf (c spool) == idOf (c T.int)
    && (builtins.tryEval (T.typeEq (c spool) (c slack))).value or false == false;
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
  construct = [ "a-container-over-a-type-copy-has-no-identity" ];
  check = asserts (
    builtins.all hasNoIdentity containers
    && picks [ (T.listOf slack) ] [ "x" ] == [ "x" ]
    && picks [ (T.listOf spool) ] [ 1 ] == [ 1 ]
  );
}
