# ── C17 — the identity-key set closes at the KIND boundary (ADR-0016 ruling 5, ADR-0033) ──
# Read off the composed VALUES, not the delivery projection: an instance's `id_hash` and its
# published key set are schema data, and the projection carries neither.
{ genValues, inputs }:
let
  c17Schema = inputs.gen.lib.substrate.schema;
  c17Pewter = genValues.thimbles.pewter;
  c17Thimble = genValues.schema.thimble;
  c17Bobbin = genValues.schema.bobbin;
in
{
  inherit
    c17Schema
    c17Pewter
    c17Thimble
    c17Bobbin
    ;
}
