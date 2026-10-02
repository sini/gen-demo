# `derived-type-keeps-its-derivation` — C133, den-hoag-5kic. A type derived from a completed one by
# `//` keeps the base's check and fold and loses everything closed over the base: declared twice it
# merges to its base, declared beside its base it is absorbed, and it mints as its base. gen-merge's
# `deriveType` re-completes the derivation instead. Here a `tagged` derivation of `str` merges with
# itself and stays tagged; declared beside a bare `str` it is refused in both orders, by gen-merge and
# by nixpkgs' own `lib.evalModules` folding the pair; under `listOf` it stays the element; and it is
# not `typeEq` to its base. Live controls: the base declared twice still merges, and two derivations
# of different ids refuse, so a `deriveType` refusing everything cannot pass.
#
# A derivation closing its own cycle (`tb`, id `bobbin`, den-hoag-djbhc) is described by its base's
# phrase within the budget: mounted through nixpkgs' own `lib.evalModules` its docs entry renders the
# head the same shape without the derivation renders, and a definition its check rejects is a refusal
# `tryEval` catches, where copying the base's phrase aborted all three. Live control: a definition in
# its domain is served.
{
  asserts,
  genMerge,
  inputs,
}:
{
  construct = [ "C133" ];
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
      tb = deriveType (t.nullOr (
        t.oneOf [
          t.str
          (t.attrsOf tb)
          (t.listOf tb)
        ]
      )) { id = "bobbin"; };
      vb = t.nullOr (
        t.oneOf [
          t.str
          (t.attrsOf vb)
          (t.listOf vb)
        ]
      );
      head200 = builtins.substring 0 200;
      mountTb =
        v:
        (lib.evalModules {
          modules = [
            { options.reel = lib.mkOption { type = tb; }; }
            { reel = v; }
          ];
        }).config.reel;
      tbDocs =
        (builtins.head (
          builtins.filter (o: o.name == "reel") (
            lib.optionAttrSetToDocList
              (lib.evalModules { modules = [ { options.reel = lib.mkOption { type = tb; }; } ]; }).options
          )
        )).type;
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
    && head200 tbDocs == head200 vb.description
    && !(builtins.tryEval (builtins.deepSeq (mountTb 5) null)).success
    # controls
    && declares t.str t.str
    && mountsInNixpkgs t.str t.str
    && !(declares tagged other)
    && mountTb { a = [ "x" ]; } == { a = [ "x" ]; }
  );
}
