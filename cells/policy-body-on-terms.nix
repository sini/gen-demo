# `policy-body-on-terms` — C140, den-hoag-lwbb1 unit 3. C105's guards written as `when` terms lower
# to the same literals and the pass reads C105's answers: `yoke` out (its negative literal holds
# `gusset-held` away), `collar` in. A policy body on terms derives its codomain without firing, fires
# both clauses at a silk spool and only the member at a cotton one, fires nothing where the spool is
# absent, and each fired declaration carries a minted identity.
{
  asserts,
  whenPass,
  whenYoke,
  trimCodomain,
  trimFired,
  trimFiredCotton,
  trimAbsent,
}:
let
  T = included: {
    flag = "T";
    inherit included;
  };
  strip = map (d: builtins.removeAttrs d [ "__mint" ]);
in
{
  construct = [ "policy-body-on-terms-its-guards-as-when-terms" ];
  check = asserts (
    whenPass.adjudication.outcome == "admitted"
    && whenPass.resolve "yoke:bolt" == T false
    && whenPass.resolve "collar:bolt" == T true
    && whenYoke == [ "gusset-held:bolt" ]
    &&
      trimCodomain == {
        emits = [ "trim" ];
        binds = [ "thread" ];
        suppresses = [ "overlock" ];
      }
    &&
      strip trimFired == [
        {
          ctor = "suppress";
          target = "overlock";
        }
        {
          ctor = "member";
          kind = "trim";
          payload.thread = "silk";
        }
      ]
    &&
      strip trimFiredCotton == [
        {
          ctor = "member";
          kind = "trim";
          payload.thread = "cotton";
        }
      ]
    && trimAbsent == [ ]
    && builtins.all (d: builtins.substring 0 12 (d.__mint.minted or "") == "rule-firing:") trimFired
  );
}
