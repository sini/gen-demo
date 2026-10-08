# `escape-retired-closure-crosses-the-door` — C159, den-hoag-lwbb1 unit 3 U3r. gen-program's declared
# escape and its firing path are each refused by name, `policy-body/escape-retired`, and the refusal
# names the gen-rules door; the same record handed to `admit` is not the normal form and is refused
# `policy-body/skeleton-malformed`; the same closure, lowered at a rule position, fires through that
# door within its contract.
{
  asserts,
  c159Escape,
  c159FireEscape,
  c159Admitted,
  c159DoorFired,
}:
let
  refusedAs = code: r: (r.refused or false) && r.code == code;
  retired = refusedAs "policy-body/escape-retired";
in
{
  construct = [ "escape-is-retired-a-closure-crosses-the-door" ];
  check = asserts (
    retired c159Escape
    && retired c159FireEscape
    && refusedAs "policy-body/skeleton-malformed" c159Admitted
    && builtins.match ".*gen-rules door.*" c159Escape.message != null
    &&
      map (d: builtins.removeAttrs d [ "__mint" ]) c159DoorFired == [
        {
          ctor = "member";
          kind = "selvage";
          payload.weft = "brass";
        }
      ]
  );
}
