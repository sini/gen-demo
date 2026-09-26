# `schema-containment-topology` — C84, den-hoag-4kh.53.51. A schema hierarchy — `damask` contains
# `faille`, `faille` contains `picot` and `gusset`, `grosgrain` stands alone — read through the
# schema's own introspection: the containment roots, the leaves, one kind's parent, and one
# container's children IN ORDER. gen-schema reads these answers off gen-graph over one accessor
# oriented container to contained; a construction reading it contained to container swaps the first
# two, and one that loses the kind-name order of children changes the fourth.
{
  asserts,
  genMerge,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  s =
    (genMerge.evalModuleTree {
      modules = [
        { options.schema = schema.mkSchemaOption { }; }
        {
          config.schema = {
            grosgrain = { };
            damask = { };
            faille.parent = "damask";
            picot.parent = "faille";
            gusset.parent = "faille";
          };
        }
      ];
    }).config.schema;
in
{
  construct = [ "C84" ];
  check = asserts (
    s._roots == [
      "damask"
      "grosgrain"
    ]
    &&
      s._leaves == [
        "grosgrain"
        "gusset"
        "picot"
      ]
    && s._topology.picot.parent == "faille"
    &&
      s._topology.faille.children == [
        "gusset"
        "picot"
      ]
  );
}
