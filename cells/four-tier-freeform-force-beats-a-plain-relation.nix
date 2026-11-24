# `four-tier-freeform-force-beats-a-plain-relation` — C114, den-hoag-0g61j (ADR-0029, the band rule on
# the freeform plane). den's user registry holds a user's fields on a freeform plane, `attrsOf anything`,
# and resolves each field between two contributor evaluations, the registry and the per-host relation.
# gen-merge publishes the priority a freeform key's own fold selected, so each evaluation's
# `bandedLeaves` bands its freeform `x`, and the channel moves it by band before structure:
#   · force over set: the registry (`t`) defines `x = mkForce "R"`, the relation (the root `r`, the
#     more specific) `x = "H"`. The force moves, `joinedTrace` joins it to the registry at `force` / 50,
#     and the receiver reads `R`;
#   · the control, both set: the more specific relation wins, `H`;
#   · no definition: the relation's only definition is `mkIf false`, so its record is
#     `unset: no definition` in the `unset` half, and the registry's `R` moves.
#
# Red: a gen-merge that publishes no freeform priority bands neither evaluation (`unset: freeform` on
# both), so nothing moves and the receiver reads its declared default `RD`.
{
  asserts,
  fourTier,
  genMerge,
}:
let
  gm = genMerge;
  layer =
    scope: x:
    gm.evalModuleTree { } [
      {
        _file = "${scope}.nix";
        freeformType = gm.types.attrsOf gm.types.anything;
      }
      {
        _file = "${scope}.nix";
        inherit x;
      }
    ];
  run =
    r: t:
    let
      c = fourTier.channel {
        contributions = {
          r = [ ];
          t = [ ];
        };
        evals = {
          r = layer "r" r;
          t = layer "t" t;
        };
      };
    in
    {
      inherit (c) moved received;
      joined = map (e: {
        inherit (e) contributor band;
        inherit (e.inner) priority;
      }) c.joined.joined;
      unset = map (u: { inherit (u) scope reason; }) c.joined.unset;
      unaccounted = map (u: u.scope) c.joined.unaccounted;
    };
in
{
  construct = [ "four-tier-value-channel-joined-to-provenance" ];
  check = asserts (
    run "H" (gm.mkForce "R") == {
      moved = [ "R" ];
      received = "R";
      joined = [
        {
          contributor = "t";
          band = "force";
          priority = 50;
        }
      ];
      unset = [ ];
      unaccounted = [ ];
    }
    &&
      run "H" "R" == {
        moved = [ "H" ];
        received = "H";
        joined = [
          {
            contributor = "r";
            band = "set";
            priority = 100;
          }
        ];
        unset = [ ];
        unaccounted = [ ];
      }
    &&
      run (gm.mkIf false "H") "R" == {
        moved = [ "R" ];
        received = "R";
        joined = [
          {
            contributor = "t";
            band = "set";
            priority = 100;
          }
        ];
        unset = [
          {
            scope = "r";
            reason = "unset: no definition";
          }
        ];
        unaccounted = [ ];
      }
  );
}
