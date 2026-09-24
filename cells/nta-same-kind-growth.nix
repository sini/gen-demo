# `nta-same-kind-growth` — C55, den-hoag-n6dh7 Unit 1. gen-scope's `nta` grows a node set of the
# host's OWN kind, keyed off evaluated values: a `skein` host's `strand` family is keyed by its
# evaluated `picked`, and its `twist` family is keyed by the evaluated `dye` of a `strand` child, so
# one family's key is another tree's value. `spawns` refuses both shapes (a kind naming itself in
# `below`, and a builder reading a value), which is why this cell could not be written before.
#
# C55 -- den-hoag-n6dh7 Unit 1. Live control: the same host with `picked` moved reads a different
# key set, so the growth is keyed off the value rather than fixed by the declaration.
{ asserts, genScope }:
{
  construct = [ "C55" ];
  check = asserts (
    let
      at = path: [
        {
          attr = "defs";
          def = 0;
          at = path;
        }
      ];
      skein = genScope.mkKind {
        name = "skein";
        nta.ply =
          self: id:
          let
            picked = self.get id "picked";
            d = builtins.head (self.get id "defs");
          in
          {
            strand = builtins.listToAttrs (
              map (k: {
                name = k;
                value = at [
                  "strands"
                  k
                ];
              }) picked
            );
            twist =
              if d ? twist && builtins.elem "warp" picked then
                { ${self.get (genScope.mintNtaId id "ply" "strand" "warp") "dye"} = at [ "twist" ]; }
              else
                { };
          };
      };
      run =
        picked:
        genScope.eval {
          scope = {
            nodes.hank = {
              id = "hank";
              type = "skein";
              parent = null;
              decls = {
                inherit picked;
                defs = [
                  {
                    strands = {
                      warp.dye = "madder";
                      weft.dye = "woad";
                    };
                    twist.dye = "none";
                  }
                ];
              };
            };
            nodeOrder = [ "hank" ];
            kinds = genScope.mkKinds [ skein ];
          };
          attributes = {
            children = _: _: { };
            defs =
              self: id:
              let
                n = (self.node id).decls;
              in
              if n ? seed then map (e: e.value) n.seed else n.defs;
            picked = self: id: (self.node id).decls.picked or [ ];
            dye = self: id: (builtins.head (self.get id "defs")).dye or "none";
          };
        };
      grown =
        ev:
        builtins.sort builtins.lessThan (
          map (i: (genScope.decodeNta i).key) (
            builtins.filter (i: genScope.decodeNta i != null) ev.allNodeIds
          )
        );
      both = run [
        "warp"
        "weft"
      ];
    in
    grown both == [
      "madder"
      "warp"
      "weft"
    ]
    && builtins.all (i: (both.node i).type == "skein") both.allNodeIds
    && builtins.length both.allNodeIds == 4
    && grown (run [ "weft" ]) == [ "weft" ]
  );
}
