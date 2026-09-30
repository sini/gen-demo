# `spawn-grows-a-declared-kind` — C112, den-hoag-39b95. gen-scope's `spawns` grows a node set by
# one rank of the declared kind order: a `selvage` host's `picot` spawn reads the host's own
# declarations through the spawn handle (`self.node`, never an evaluated attribute) and returns
# children keyed by identity with no `id`, `type` or `parent` — the substrate stamps all three, the
# `id` from the key. Each child is then an ordinary node whose attributes evaluate.
#
# Red before gen-scope stamped the `id`: an id-less child aborted `attribute 'id' missing`, uncatchably.
# Live control: a host declaring no picots spawns none, so the set grows off the declaration.
{ asserts, genScope }:
{
  construct = [ "C112" ];
  check = asserts (
    let
      kinds = genScope.mkKinds [
        (genScope.mkKind { } "picot")
        (genScope.mkKind {
          below = [ "picot" ];
          spawns.picot =
            self: id:
            builtins.listToAttrs (
              map (p: {
                name = "picot:${p}@${id}";
                value.decls.shade = "${p}-${(self.node id).decls.dye}";
              }) ((self.node id).decls.picots or [ ])
            );
        } "selvage")
      ];
      ev =
        genScope.eval { }
          {
            children = _: _: { };
            shade = self: id: (self.node id).decls.shade or null;
          }
          (
            genScope.buildRoots {
              inherit kinds;
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
      grown = [
        "picot:ruche@lace"
        "picot:tatting@lace"
      ];
    in
    builtins.sort builtins.lessThan ev.allNodeIds == [
      "fringe"
      "lace"
    ]
    ++ grown
    && builtins.all (
      k:
      let
        n = ev.node k;
      in
      n.id == k && n.type == "picot" && n.parent == "lace"
    ) grown
    && ev.get "picot:tatting@lace" "shade" == "tatting-madder"
  );
}
