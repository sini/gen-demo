# `spawn-labels-two-registries-of-one-kind` — den-hoag-f77c8 U1a. A `selvage` host declares two
# spawn entries producing ONE kind, `picot`: `edging` and `trim`. Each child carries the label of
# the entry that grew it as `containedAs`, stamped by gen-scope, beside the `type` both share; and
# over gen-select's scope context `sel.kind` of the `picot` kind selects both. The root carries the
# label `buildRoots`' `containedAs` gives it, and an unlabelled root carries none.
#
# Red before the label: `spawns` was keyed by the produced kind, so a host had one `picot` builder
# and the label-keyed form was refused at `mkKind`; no record carried `containedAs`. Live control: a
# builder asserting its own `containedAs` is refused, as one asserting `type` is.
{
  asserts,
  genMerge,
  genScope,
  genSelect,
  inputs,
}:
let
  schema = inputs.gen.lib.substrate.schema;
  kindTree =
    (genMerge.evalModuleTree { } [
      { options.schema = schema.mkSchemaOption { }; }
      { config.schema.picot = { }; }
      { config.schema.selvage = { }; }
    ]).config.schema;
  picotsOf = label: _: id: {
    "picot:${label}@${id}" = {
      decls = { };
    };
  };
  evWith =
    spawns:
    genScope.eval { } { children = _: _: { }; } (
      genScope.buildRoots {
        kinds = genScope.mkKinds [
          (genScope.mkKind { kindValue = kindTree.picot; } "picot")
          (genScope.mkKind {
            below = [ "picot" ];
            kindValue = kindTree.selvage;
            inherit spawns;
          } "selvage")
        ];
        parentGraph = genScope.overlay (genScope.vertex "lace") (genScope.vertex "fringe");
        types = {
          lace = "selvage";
          fringe = "selvage";
        };
        containedAs.lace = "bolts";
      }
    );
  ev = evWith {
    edging = {
      produced = "picot";
      builder = picotsOf "edging";
    };
    trim = {
      produced = "picot";
      builder = picotsOf "trim";
    };
  };
  kids = genScope.childrenIds ev "lace";
  ctx = genSelect.adapters.scope.mkContext {
    inherit (ev) node;
    childrenIds = genScope.childrenIds ev;
    entryFor = id: ev.node id;
  };
  refused = v: !(builtins.tryEval (builtins.deepSeq v v)).success;
in
{
  construct = [ "spawn-labels-two-registries-of-one-kind" ];
  check = asserts (
    kids == [
      "picot:edging@lace"
      "picot:trim@lace"
    ]
    &&
      map (id: (ev.node id).containedAs) kids == [
        "edging"
        "trim"
      ]
    &&
      map (id: (ev.node id).type) kids == [
        "picot"
        "picot"
      ]
    && builtins.all (id: genSelect.matches (genSelect.kind kindTree.picot) id ctx) kids
    && !(genSelect.matches (genSelect.kind kindTree.picot) "lace" ctx)
    && (ev.node "lace").containedAs == "bolts"
    && !((ev.node "fringe") ? containedAs)
    && refused (
      (evWith {
        edging = {
          produced = "picot";
          builder = _: id: {
            "picot:x@${id}" = {
              containedAs = "asserted";
              decls = { };
            };
          };
        };
      }).node
        "picot:x@lace"
    )
  );
}
