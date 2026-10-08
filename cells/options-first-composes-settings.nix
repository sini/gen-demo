# `options-first-composes-settings` — C91, den-hoag-7gp66 P2 L5. The same law as
# `options-first-composes`, at gen-settings and gen-aspects. `resolve` is gen-settings' `resolveOne`
# with its options stated once (`strict = false`) and its schema supplied, then mapped over two layer
# stacks, the subject, last: each stack's stray `weft` is admitted, where the same door under `{ }`
# refuses it (E2). `addressed` is `renderAddress { field; }` mapped over two aspects. `minted` is
# gen-aspects' `instanceOf` with its `scope` option stated once, then applied to two shuttles: each
# instance carries the handed scope, where `{ }` carries none. Each door's contract is read AS DATA
# (`__contract`, which carries no retired list), and four refusals are caught at the options
# application: an unknown option, the unmigrated one-record calls of `resolveOne` and `instanceOf`
# (`layers`, `aspect` are no options), and `classes`, a `cnf` key the library no longer reads (a class
# is a `keySemantics` entry), refused as any unknown key (den-hoag-c54n4).
{
  asserts,
  genSettings,
  genAspects,
  inputs,
}:
let
  entity = n: inputs.gen.lib.substrate.identity.hashIdentity "entity" [ "name" ] (_: n);
  bobbin = {
    name = "bobbin";
    id_hash = "b0bb1ab0bb1ab0bb";
  };
  thimble = {
    name = "thimble";
    id_hash = "7h1mb1e07h1mb1e0";
  };
  schema = genSettings.mkSchema bobbin { spool.default = "linen"; };
  layer = value: {
    scope = { };
    rendered = "loom";
    via = null;
    inherit value;
  };
  stacks = [
    [
      (layer {
        spool = "silk";
        weft = 1;
      })
    ]
    [
      (layer {
        spool = "wool";
        weft = 2;
      })
    ]
  ];
  resolve = genSettings.resolveOne { strict = false; } schema;
  addressed = genSettings.renderAddress { field = "spool"; };

  shuttle = genAspects.guard (genAspects.pred.has "shuttle") { description = "pick"; };
  kept.selvage = "kept";
  minted = genAspects.instanceOf { } { scope = kept; };
  at = s: {
    aspect = genAspects.aspectId [ ] { name = "pick"; };
    context.shuttle = s;
    sources.shuttle = entity s;
  };

  refuses = e: !(builtins.tryEval (builtins.seq e null)).success;
  answers = e: (builtins.tryEval (builtins.deepSeq e null)).success;
in
{
  construct = [ "doors-options-first-and-composed" ];
  check = asserts (
    map (st: (resolve st).value.spool) stacks == [
      "silk"
      "wool"
    ]
    # control: the same door under `{ }` refuses the stray field (E2)
    && !answers (genSettings.resolveOne { } schema (builtins.head stacks)).value
    &&
      map addressed [
        bobbin
        thimble
      ] == [
        "aspect(bobbin#b0bb1ab0).spool"
        "aspect(thimble#7h1mb1e0).spool"
      ]
    &&
      map (s: (minted (at s) shuttle).scope.selvage or null) [
        "ash"
        "elm"
      ] == [
        "kept"
        "kept"
      ]
    # control: `instanceOf { } { }` carries no handed scope
    && (genAspects.instanceOf { } { } (at "ash") shuttle).scope == { }
    &&
      genSettings.resolveOne.__contract.optional == [
        "resolveRef"
        "strict"
      ]
    &&
      genSettings.injectAspectSettings.__contract.next.required == [
        "aspect"
        "settings"
      ]
    && !(genAspects.instanceOf.__contract ? retired)
    && (genAspects.instanceOf { }).__contract.optional == [ "scope" ]
    && refuses (genSettings.resolveOne { weft = 1; })
    && refuses (
      genSettings.resolveOne {
        inherit schema;
        layers = builtins.head stacks;
      }
    )
    && refuses (genAspects.instanceOf { } (at "ash" // { value = shuttle; }))
    && refuses (genAspects.instanceOf { classes.nixos = { }; })
    # control: the same predicate admits a well-formed options application
    && !refuses (genSettings.resolveOne { })
  );
}
