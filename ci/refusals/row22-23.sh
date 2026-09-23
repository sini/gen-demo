# shellcheck shell=bash
# ── row 22/23 -- `mintAttachmentId`/`parseParent`, the multi-parent EXTEND (gen-scope
# `den-hoag-4kh.53.13`). NOT a T5/ADR-0025 refusal row -- neither function names a door this
# file's `check` harness exercises by plant/unplant; it is placed here only because this is where
# the repo's "one let-prefixed base, `check`-call-per-arm" idiom and `nix eval --raw` harness
# already live, and because `refusals.sh` is the devshell command CI schedules (this file's own
# header). `shaft1`/`shaft2`/`heddle` are ADR-0035 weaving vocabulary, chosen distinct from
# row17/18's own `selvage`/`bobbin`/`warp`/`thread`/`bolt` family to stay visibly independent of
# that row rather than implying a jointly-verified shared fixture. ──
heddleBase='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genScope = gen.lib.substrate.scope;
  kinds = genScope.mkKinds [
    (genScope.mkKind { name = "shaft"; })
    (genScope.mkKind { name = "heddle"; })
  ];
  built = genScope.buildRoots {
    parentGraph = genScope.overlay
      (genScope.edge (genScope.mintAttachmentId "heddle" [ "shaft1" "shaft2" ] "shaft1") "shaft1")
      (genScope.edge (genScope.mintAttachmentId "heddle" [ "shaft1" "shaft2" ] "shaft2") "shaft2");
    types.shaft1 = "shaft"; types.shaft2 = "shaft";
    types."heddle@shaft1" = "heddle"; types."heddle@shaft2" = "heddle";
    decls.shaft1 = { }; decls.shaft2 = { };
    decls."heddle@shaft1" = { }; decls."heddle@shaft2" = { };
    kinds = kinds;
  };
  nodes = built.nodes;
in '

# row22 -- O10's first three facts: both minted ids present, both `.parent` fields correct, and
# `parseParent` round-trips both directions plus the bare-root null case (spec §2.4/O10).
row22="$heddleBase"'builtins.toJSON {
  bothIdsPresent = builtins.elem "heddle@shaft1" (builtins.attrNames nodes) && builtins.elem "heddle@shaft2" (builtins.attrNames nodes);
  parentField1 = nodes."heddle@shaft1".parent;
  parentField2 = nodes."heddle@shaft2".parent;
  parseRoundTrip1 = genScope.parseParent "heddle@shaft1";
  parseRoundTrip2 = genScope.parseParent "heddle@shaft2";
  bareParseIsNull = genScope.parseParent "shaft1" == null;
}'
check "row22 multi-parent attachment (both ids minted, both parent fields, parseParent round-trips, bare root parses null)" \
  "$row22" 0 "" \
  "$tmpdir/row22.err" \
  '{"bareParseIsNull":true,"bothIdsPresent":true,"parentField1":"shaft1","parentField2":"shaft2","parseRoundTrip1":"shaft1","parseRoundTrip2":"shaft2"}'

# row23 -- the fourth oracle fact, its own arm: a single-element `parents` list leaves `bareId`
# unchanged (the id-stability property, spec §2.2), a third root with exactly one parent.
row23="$heddleBase"'builtins.toJSON (genScope.mintAttachmentId "spindle" [ "shaft1" ] "shaft1")'
check "row23 single-parent id stability (mintAttachmentId returns bareId unchanged when parents has exactly one member)" \
  "$row23" 0 "" \
  "$tmpdir/row23.err" \
  '"spindle"'
