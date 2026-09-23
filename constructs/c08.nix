# ── C8 — the contribution protocol (ADR-0012, ADR-0014): shape unions commutatively,
# content folds by positional authority. Three contributions, only one carrying edges.
{ genAssemble, genScope }:
let
  c8Thimbles = {
    name = "thimbles";
    vertices = [
      "pewter"
      "damask"
    ];
    decls = {
      pewter = {
        spool = "linen";
        aspects = [ "stitch" ];
      };
      damask = {
        spool = "sateen";
        aspects = [ ];
      };
    };
  };
  c8Bobbins = {
    name = "bobbins";
    vertices = [
      "grosgrain"
      "faille"
    ];
    edgeGraphs = [
      {
        label = "tacks";
        graph = genScope.edge "pewter" "grosgrain";
      }
    ];
    decls = {
      grosgrain = {
        gauge = "fine";
      };
      faille = {
        gauge = "coarse";
      };
    };
  };
  c8Overlay = {
    name = "overlay"; # a later layer, no members of its own
    vertices = [ ];
    decls.pewter = {
      spool = "gros-de-tours";
      tacked = true;
    };
  };
  c8Contributions = [
    c8Thimbles
    c8Bobbins
    c8Overlay
  ];
  c8Assembled = genAssemble.assemble { contributions = c8Contributions; };
  c8Unioned = genAssemble.union { contributions = c8Contributions; };
  c8Permuted = genAssemble.union {
    contributions = [
      c8Overlay
      c8Thimbles
      c8Bobbins
    ];
  };
in
{
  inherit
    c8Thimbles
    c8Bobbins
    c8Overlay
    c8Contributions
    c8Assembled
    c8Unioned
    c8Permuted
    ;
}
