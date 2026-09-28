# `quotient-representative` — C89, den-hoag-q8pwl. A quotient carrier converges on a class
# representative, not a fixed point of its step, and gen-scope's evaluator says so (ADR-0020
# never-silence, ADR-0008 §3). `loom`'s `weave` ascends under key-set inclusion — a quotient, whose
# raw values keep churning inside the class — and `getRepresentative` answers it tagged
# `gen-scope/quotient-representative`; the raw `get` on it is refused catchably, and its message is
# `refusals` row 103's. Live control: `shuttle`, a `quotient = false` sibling on the same node,
# answers raw through `get`, so an evaluator refusing every circular demand cannot pass.
{ asserts, genScope }:
let
  r =
    genScope.eval { }
      {
        children = _self: _id: { };
        imports = _self: _id: [ ];
        weave =
          genScope.circular
            {
              carrier = {
                bottom = { };
                leq = a: b: builtins.all (k: b ? ${k}) (builtins.attrNames a);
                height = 3;
                quotient = true;
              };
            }
            (
              _self: _id: prev:
              let
                n = builtins.length (builtins.attrNames prev);
              in
              builtins.mapAttrs (_: v: v + 1) prev // (if n >= 3 then { } else { "warp${toString n}" = 0; })
            );
        shuttle =
          genScope.circular
            {
              carrier = {
                bottom = 0;
                leq = a: b: a <= b;
                height = 3;
                quotient = false;
              };
            }
            (
              self: id: prev:
              if prev >= (self.node id).decls.ply then prev else prev + 1
            );
      }
      (
        genScope.buildRoots {
          parentGraph = genScope.vertex "loom";
          importGraph = genScope.empty;
          decls.loom.ply = 3;
          types = { };
        }
      );
in
{
  construct = [ "C89" ];
  check = asserts (
    r.getRepresentative "loom" "weave" == {
      _type = "gen-scope/quotient-representative";
      representative = {
        warp0 = 3;
        warp1 = 2;
        warp2 = 1;
      };
    }
    && !(builtins.tryEval (builtins.deepSeq (r.get "loom" "weave") true)).success
    && r.get "loom" "shuttle" == 3
  );
}
