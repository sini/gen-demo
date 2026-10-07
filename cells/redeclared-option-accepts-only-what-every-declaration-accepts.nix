# `redeclared-option-accepts-only-what-every-declaration-accepts` — den-hoag-l1j4q (owner-ruled 2026-10-06,
# the meet). One option declared by several types serves a definition only if EVERY declared check accepts
# it, where nixpkgs' later-operand rule drops a check. Each form's verdict per value is pinned:
#  - `pair1`/`pair2`: gen `int` beside a nixpkgs partner rejecting 7, both orders; 7 and "s" refused, 8 served.
#  - `distinct`: two DISTINCT partners (rejecting 7 and 9) and gen `int`, in that order, so a step's operand
#    is already a met record over a foreign carrier; 7 and 9 refused, 8 served.
#  - `wrapped`: gen `listOf int`, the same wrapped by `addCheck` (rejecting 9), and a nixpkgs `listOf`
#    partner (rejecting 7), in that order; [7] and [9] refused, [8] served.
# Red where any step serves a value one declaration rejects (gen-merge before the meet refused these pairs
# outright, so its `8`s read REFUSED and red too).
{
  asserts,
  genMerge,
  lib,
  meetPartner,
  meetRead,
}:
let
  gi = genMerge.types.int;
  gl = genMerge.types.listOf gi;
  forms = {
    pair1 = {
      ts = [
        gi
        (meetPartner 7)
      ];
      v = {
        "7" = "REFUSED";
        s = "REFUSED";
        "8" = 8;
      };
      lift = x: x;
    };
    pair2 = {
      ts = [
        (meetPartner 7)
        gi
      ];
      v = {
        "7" = "REFUSED";
        s = "REFUSED";
        "8" = 8;
      };
      lift = x: x;
    };
    distinct = {
      ts = [
        (meetPartner 7)
        (meetPartner 9)
        gi
      ];
      v = {
        "7" = "REFUSED";
        "9" = "REFUSED";
        "8" = 8;
      };
      lift = x: x;
    };
    wrapped = {
      ts = [
        gl
        (lib.types.addCheck gl (l: builtins.all (x: x != 9) l))
        (lib.types.listOf (meetPartner 7))
      ];
      v = {
        "7" = "REFUSED";
        "9" = "REFUSED";
        "8" = [ 8 ];
      };
      lift = x: [ x ];
    };
  };
  val = k: if k == "s" then "s" else lib.toInt k;
  verdicts = builtins.mapAttrs (
    _: f: builtins.mapAttrs (k: _: meetRead f.ts (f.lift (val k))) f.v
  ) forms;
in
{
  construct = [ "redeclared-option-accepts-only-what-every-declaration-accepts" ];
  check = asserts (builtins.all (n: forms.${n}.v == verdicts.${n}) (builtins.attrNames forms));
}
