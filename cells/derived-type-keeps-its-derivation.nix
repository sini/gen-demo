# `derived-type-keeps-its-derivation` — C126, den-hoag-5kic. A type derived from a completed one by
# `//` keeps the base's check and fold and loses everything closed over the base: declared twice it
# merges to its base, declared beside its base it is absorbed, and it mints as its base. gen-merge's
# `deriveType` re-completes the derivation instead. Here a `tagged` derivation of `str` merges with
# itself and stays tagged; declared beside a bare `str` it is refused in both orders, by gen-merge and
# by nixpkgs' own `lib.evalModules` folding the pair; under `listOf` it stays the element; and it is
# not `typeEq` to its base. Live controls: the base declared twice still merges, and two derivations
# of different ids refuse, so a `deriveType` refusing everything cannot pass.
{
  asserts,
  genMerge,
  inputs,
}:
{
  construct = [ "C126" ];
  check = asserts (
    let
      inherit (inputs.gen.lib.modules.types) typeEq;
      inherit (genMerge)
        deriveType
        mergeTypes
        evalModuleTree
        mkOption
        ;
      t = genMerge.types;
      lib = inputs.nixpkgs.lib;
      tagged = deriveType t.str {
        id = "tagged";
        fields = _: { description = "a tagged string"; };
      };
      other = deriveType t.str { id = "labelled"; };
      idOf = v: if v == null then null else v.__derivation.id or null;
      declares =
        a: b:
        (builtins.tryEval (
          builtins.deepSeq
            (evalModuleTree {
              modules = [
                { options.spool = mkOption { type = a; }; }
                { options.spool = mkOption { type = b; }; }
                { spool = "sateen"; }
              ];
            }).config.spool
            null
        )).success;
      mountsInNixpkgs =
        a: b:
        (builtins.tryEval (
          builtins.deepSeq
            (lib.evalModules {
              modules = [
                { options.spool = lib.mkOption { type = a; }; }
                { options.spool = lib.mkOption { type = b; }; }
                { spool = "sateen"; }
              ];
            }).config.spool
            null
        )).success;
      bobbins = t.listOf tagged;
    in
    idOf (mergeTypes tagged tagged) == "tagged"
    && declares tagged tagged
    && !(declares t.str tagged)
    && !(declares tagged t.str)
    && !(mountsInNixpkgs t.str tagged)
    && !(mountsInNixpkgs tagged t.str)
    && mountsInNixpkgs tagged tagged
    && idOf (mergeTypes bobbins bobbins).carries.element == "tagged"
    && mergeTypes bobbins (t.listOf t.str) == null
    && tagged.check "sateen"
    && !(tagged.check 1)
    && !(typeEq tagged t.str)
    && typeEq tagged tagged
    # controls
    && declares t.str t.str
    && mountsInNixpkgs t.str t.str
    && !(declares tagged other)
  );
}
