# `a-root-read-answers-beside-an-incoherent-root` — den-hoag-25mup. gen-scope decides a node's kind-value coherence at
# that node's own read: a hand-built record of `thimble` roots `a` and `b`, kinds carrying gen-schema kind values,
# with `b` carrying the `needle` kind's value. Every read of `a` — `node`, `get … children`, gen-select's
# `sel.kind` match over its scope adapter, and `evalDebug`'s `node` — answers what it answers on the coherent twin.
#
# Red before the move: the scope door scanned every node at the evaluator's entry, so each of the four reads of
# `a` refused naming `b`. The refusal of `b` itself, by name, through `eval` and `evalDebug`, is the refusal row
# of the same name.
{
  asserts,
  genMerge,
  genSchema,
  genScope,
  genSelect,
}:
let
  schema =
    (genMerge.evalModuleTree { } [
      { options.schema = genSchema.mkSchemaOption { }; }
      {
        config.schema = {
          thimble.options.spool = genMerge.mkOption {
            type = genMerge.types.str;
            default = "linen";
          };
          needle.options.eye = genMerge.mkOption {
            type = genMerge.types.str;
            default = "round";
          };
        };
      }
    ]).config.schema;
  kinds = genScope.mkKinds [
    (genScope.mkKind { kindValue = schema.needle; } "needle")
    (genScope.mkKind {
      kindValue = schema.thimble;
      below = [ "needle" ];
    } "thimble")
  ];
  scopeOf = bValue: {
    inherit kinds;
    nodeOrder = [
      "a"
      "b"
    ];
    nodes =
      builtins.mapAttrs
        (id: kindValue: {
          inherit id kindValue;
          type = "thimble";
          parent = null;
          decls = { };
        })
        {
          a = schema.thimble;
          b = bValue;
        };
  };
  readsOfA =
    scope:
    let
      ev = genScope.eval { } { children = _: _: { }; } scope;
      ctx = genSelect.adapters.scope.mkContext {
        inherit (ev) node;
        childrenIds = genScope.childrenIds ev;
        # the node is its own entry, so `sel.kind` reads the kind value the node carries
        entryFor = ev.node;
      };
    in
    {
      node = (ev.node "a").id;
      children = ev.get "a" "children";
      kind = genSelect.matches (genSelect.kind schema.thimble) "a" ctx;
      debug = ((genScope.evalDebug { } { children = _: _: { }; } scope).node "a").id;
    };
  incoherent = readsOfA (scopeOf schema.needle);
in
{
  construct = [ "a-root-read-answers-beside-an-incoherent-root" ];
  check = asserts (
    incoherent == readsOfA (scopeOf schema.thimble)
    &&
      incoherent == {
        node = "a";
        children = { };
        kind = true;
        debug = "a";
      }
  );
}
