# ── den-hoag-l1j4q — the meet. A raw nixpkgs leaf partner REJECTING `n` that keeps itself when joined with a
# payload-free `int` (its own `typeMerge`), and a reader of one option declared once per type in `ts`, in
# gen-merge's engine, as the served value or "REFUSED".
{ genMerge, lib }:
let
  meetPartner =
    n:
    let
      self = lib.mkOptionType {
        name = "int";
        check = x: builtins.isInt x && x != n;
        merge = lib.options.mergeEqualOption;
        functor = lib.types.defaultFunctor "int" // {
          type = _: self;
          payload.refined = true;
          binOp = a: _b: a;
        };
        typeMerge =
          f:
          if f.name == "int" && (f.payload == null || f.payload == { refined = true; }) then self else null;
      };
    in
    self;
  meetRead =
    ts: v:
    let
      r = genMerge.evalModuleTree { } (
        map (t: { options.x = genMerge.mkOption { type = t; }; }) ts ++ [ { x = v; } ]
      );
      tried = builtins.tryEval (builtins.deepSeq r.config.x r.config.x);
    in
    if tried.success then tried.value else "REFUSED";
in
{
  inherit meetPartner meetRead;
}
