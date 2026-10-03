# `kind-subsumption-across-trees` — C166, den-hoag-l0y (foreign-kind arm). The owner's topology on
# gen-aspects, across two trees: a framework `mkAspectSchema` with one class, whose `aspect` declares
# `weft`, and a consumer `mkAspectSchema` holding that class and one more, whose own `aspect` inherits
# the framework's `aspect` BY VALUE and declares `warp`. gen-aspects fixes the kind's name, so the
# consumer's kind carries the name of the value it inherits; the tree's entry at that name is the
# declaring kind itself, so the value is foreign, and it is decided before the kind's own mark (which
# is in flight) is read. The consumer's options hold the framework's, its `inherits` and its `_edges`
# row hold the framework VALUE, and over one registry context `sel.subkind` of the framework kind
# matches both nodes while `sel.kind` matches only the framework's. The refused twins (a consumer
# schema omitting the framework's class, and a `//` copy of the framework kind) are red here by
# `tryEval` and by name in `refusals` row 140. A THIRD tree (den-hoag-4i0o5): the consumer's `aspect` is
# re-layered through one helper that tags each application with its own module `_file`, applied as
# framework <- consumer <- site; the site's options are the union. Without the tag the two applications
# share a content witness, and the chain is refused by a text naming both readings and the remedy
# (`refusals` row 141). Red when the topology aborts or any conjunct fails.
{
  asserts,
  genAspects,
  genMerge,
  genSelect,
}:
let
  intOpt = genMerge.mkOption { type = genMerge.types.int; };
  ev = modules: (genMerge.evalModuleTree { inherit modules; }).config;
  framework = genAspects.mkAspectSchema { keySemantics.loom.category = "class"; };
  consumerSchema =
    keySemantics:
    genAspects.mkAspectSchema {
      inherit keySemantics;
    };
  both = consumerSchema {
    loom.category = "class";
    spindle.category = "class";
  };
  frameworkAspect =
    (ev [
      { options.schema = framework.schemaOption; }
      { config.schema.aspect.options.weft = intOpt; }
    ]).schema.aspect;
  consumerTree =
    s: parent:
    (ev [
      { options.schema = s.schemaOption; }
      {
        config.schema.aspect = {
          inherits = [ parent ];
          options.warp = intOpt;
        };
      }
    ]).schema;
  consumer = consumerTree both frameworkAspect;
  consumerAspect = consumer.aspect;
  isFramework = v: !(builtins.isString v) && v.__mint.minted == frameworkAspect.__mint.minted;
  ctx = genSelect.adapters.registry.mkContext {
    nodes = [
      "framework"
      "consumer"
    ];
    data = id: { id_hash = "h-${id}"; };
    parent = _: null;
    kindFor =
      id:
      {
        framework = frameworkAspect;
        consumer = consumerAspect;
      }
      .${id};
  };
  matches = sel: id: genSelect.matches sel id ctx;
  opts = k: builtins.attrNames k.options;
  refused = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
  inheritsEdges = builtins.filter (e: e.type == "inherits") consumer._edges;
  layer = tag: parent: {
    _file = "aspect-layer:${tag}";
    config.schema.aspect = {
      inherits = [ parent ];
      options.warp = intOpt;
    };
  };
  layered =
    tag: parent:
    (ev [
      { options.schema = both.schemaOption; }
      (layer tag parent)
    ]).schema.aspect;
  siteAspect = layered "site" (layered "consumer" frameworkAspect);
in
{
  construct = [ "C166" ];
  check = asserts (
    opts consumerAspect == [
      "warp"
      "weft"
    ]
    && builtins.length consumerAspect.inherits == 1
    && builtins.all isFramework consumerAspect.inherits
    && builtins.length inheritsEdges == 1
    && builtins.all (e: isFramework e.to) inheritsEdges
    && matches (genSelect.subkind frameworkAspect) "framework"
    && matches (genSelect.subkind frameworkAspect) "consumer"
    && matches (genSelect.kind frameworkAspect) "framework"
    && !(matches (genSelect.kind frameworkAspect) "consumer")
    && refused (
      opts (consumerTree (consumerSchema { spindle.category = "class"; }) frameworkAspect).aspect
    )
    && refused (opts (consumerTree both (frameworkAspect // { options = { }; })).aspect)
    &&
      opts siteAspect == [
        "warp"
        "weft"
      ]
  );
}
