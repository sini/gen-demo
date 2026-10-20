# `spawn-keeps-production-order` — den-hoag-jlmmr. A `selvage` host's `picot` spawn returns its
# children as a list of `{ name; value; }`, `tatting` before `ruche`, and every ordered read of the
# node set answers in that order: `childrenIds` and `allNodeIds` list `picot:tatting@lace` first,
# where the names' order puts `ruche` first. `fringe`, declaring no picots, returns an empty list.
#
# Red before gen-scope took a list: the builder's list aborted `expected a set but found a list`,
# uncatchably. Live control: the same builder through `listToAttrs` reads the names' order.
{ asserts, genScope }:
{
  construct = [ "spawn-keeps-the-order-its-builder-wrote" ];
  check = asserts (
    let
      evWith =
        form:
        genScope.eval { }
          {
            children = _: _: { };
          }
          (
            genScope.buildRoots {
              kinds = genScope.mkKinds [
                (genScope.mkKind { } "picot")
                (genScope.mkKind {
                  below = [ "picot" ];
                  spawns.picot =
                    self: id:
                    form (
                      map (p: {
                        name = "picot:${p}@${id}";
                        value.decls.shade = "${p}-${(self.node id).decls.dye}";
                      }) ((self.node id).decls.picots or [ ])
                    );
                } "selvage")
              ];
              parentGraph = genScope.overlay (genScope.vertex "lace") (genScope.vertex "fringe");
              types = {
                lace = "selvage";
                fringe = "selvage";
              };
              decls = {
                lace = {
                  dye = "madder";
                  picots = [
                    "tatting"
                    "ruche"
                  ];
                };
                fringe.dye = "woad";
              };
            }
          );
      ev = evWith (xs: xs);
    in
    genScope.childrenIds ev "lace" == [
      "picot:tatting@lace"
      "picot:ruche@lace"
    ]
    &&
      ev.allNodeIds == [
        "lace"
        "picot:tatting@lace"
        "picot:ruche@lace"
        "fringe"
      ]
    && genScope.childrenIds ev "fringe" == [ ]
    &&
      genScope.childrenIds (evWith builtins.listToAttrs) "lace" == [
        "picot:ruche@lace"
        "picot:tatting@lace"
      ]
  );
}
