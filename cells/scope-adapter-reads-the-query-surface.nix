# `scope-adapter-reads-the-query-surface` — den-hoag-5lgmi. A `selvage` host `lace` selects one
# `hem` child, spawns two `picot` children written `tatting` before `ruche`, and carries one `nta`
# `fold`. gen-select's scope context, built over gen-scope's `childrenIds`, answers `children` as
# gen-scope does: all four, in production order, and `has` reaches the spawned and the `nta` child.
#
# Red before the adapter read the query surface: `children` read the `children` attribute alone,
# `[ "hem:lace" ]`, so `has` missed both. Live control: the same builder through `listToAttrs`
# reads the names' order, `ruche` first.
{
  asserts,
  genScope,
  genSelect,
}:
{
  construct = [ "scope-adapter-reads-the-query-surface" ];
  check = asserts (
    let
      evWith =
        form:
        let
          scope = genScope.buildRoots {
            kinds = genScope.mkKinds [
              (genScope.mkKind { } "hem")
              (genScope.mkKind { } "picot")
              (genScope.mkKind {
                below = [
                  "hem"
                  "picot"
                ];
                spawns.picot =
                  _: id:
                  form (
                    map
                      (p: {
                        name = "picot:${p}@${id}";
                        value = { };
                      })
                      (
                        if id == "lace" then
                          [
                            "tatting"
                            "ruche"
                          ]
                        else
                          [ ]
                      )
                  );
                nta.fold = _: id: if id == "lace" then { pleat.box = [ ]; } else { };
              } "selvage")
            ];
            parentGraph = genScope.edge {
              from = "hem:lace";
              to = "lace";
            };
            importGraph = genScope.empty;
            decls = {
              lace = { };
              "hem:lace" = { };
            };
            types = {
              lace = "selvage";
              "hem:lace" = "hem";
            };
          };
        in
        genScope.eval { } {
          imports = _: _: [ ];
          children = _: id: if id == "lace" then { "hem:lace" = scope.nodes."hem:lace"; } else { };
        } scope;
      ctxOf =
        ev:
        genSelect.adapters.scope.mkContext {
          inherit (ev) node;
          childrenIds = genScope.childrenIds ev;
        };
      fold = genScope.mintNtaId {
        host = "lace";
        name = "fold";
        group = "pleat";
        key = "box";
      };
      ev = evWith (xs: xs);
      ctx = ctxOf ev;
      evNames = evWith builtins.listToAttrs;
      has = t: genSelect.matches (genSelect.has (genSelect.attrs { type = t; })) "lace" ctx;
    in
    ctx.children "lace" == [
      "hem:lace"
      "picot:tatting@lace"
      "picot:ruche@lace"
      fold
    ]
    && ctx.children "lace" == genScope.childrenIds ev "lace"
    && ctx.siblings "picot:ruche@lace" == genScope.siblings ev "picot:ruche@lace"
    && has "picot"
    && has "selvage"
    &&
      (ctxOf evNames).children "lace" == [
        "hem:lace"
        "picot:ruche@lace"
        "picot:tatting@lace"
        fold
      ]
  );
}
