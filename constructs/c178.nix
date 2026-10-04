# ── C178 — a declaration shadows a throwing ancestor default without forcing it (den-hoag-gayc C1,
# owner-ruled 2026-09-30). The nixpkgs mandatory-option idiom over gen-scope's one resolution
# calculus: `bolt` declares `nap = throw "…must set nap"`, and `selvage`, contained in `bolt`,
# overrides it. Under a DECLARED competition key (`group`) the nearer declaration answers and the
# ancestor's datum is never read; under a key computed from the answer (`groupBy`) every candidate's
# datum is forced, which is the strict form. `weft` declares nothing, so the ancestor IS its answer.
{
  genScope,
}:
let
  napNodes = {
    bolt = {
      id = "bolt";
      type = "fabric";
      parent = null;
      decls.nap = throw "c178: bolt's default nap was forced; a nearer declaration must shadow it";
    };
    selvage = {
      id = "selvage";
      type = "fabric";
      parent = "bolt";
      decls.nap = "brushed";
    };
    weft = {
      id = "weft";
      type = "fabric";
      parent = "bolt";
      decls = { };
    };
  };
  napScope =
    genScope.eval
      {
        parseParent = id: napNodes.${id}.parent;
      }
      {
        children = _: _: { };
        imports = _: _: [ ];
        marks = _: _: [ ];
      }
      {
        nodes = napNodes;
        nodeOrder = [
          "bolt"
          "selvage"
          "weft"
        ];
      };
  napOf = n: n.decls.nap or null;
  napUnder =
    key: id:
    (genScope.resolve (
      genScope.neron
      // {
        mode = "visible";
        dataFilter = napOf;
      }
      // key
    ) napScope id).single
      "nap";
in
{
  inherit napScope napOf;
  napDeclared = napUnder { group = "nap"; };
  napComputed = napUnder { groupBy = _: "nap"; };
  napInherited = genScope."inherit'" { } napOf napScope;
}
