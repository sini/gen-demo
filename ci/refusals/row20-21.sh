# shellcheck shell=bash
# ── rows 20/21 -- den-hoag-i546n's thunk-authorization guards (ADR-0023(c) site 3, ADR-0025 item 1).
# Both plant against `gen.lib.substrate.bind.crossing` and both mint their own identity: ADR-0016
# §2.3.1 forbids `hashIdentity` in production, and gen-bind's own fixtures name the test-only stand-in
# `_testHashIdentity` (`gen-bind/ci/tests/_crossing-fixtures.nix`), so the plant carries one by that
# name rather than reaching for the published surface. `mkOperations` is applied and its `.value`
# merged over the raw vocabulary because the identity function is the operations' formal, not the
# vocabulary's.
row20='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  x0 = gen.lib.substrate.bind.crossing;
  _testHashIdentity = kind: labels: relatumOf:
    builtins.hashString "sha256" (kind + "@" + builtins.concatStringsSep "|" (
      builtins.map (l: l + "=" + relatumOf l) (builtins.sort (a: b: a < b) labels)
    ));
  x = x0 // (x0.mkOperations { hashIdentity = _testHashIdentity; }).value;
  c = x.contractTerm;
  imp = { merge = "one"; contract = c.any; required = true; sealed = false; origin = "fixture"; satisfiedBy = null; };
  supply = { bindings.host = x.binding.plain { value = 1; mark = x.mark.open; }; proposals = { }; origins = { }; };
  proj = (x.registerSupply supply).value.projection;
  f = x.declare { imports.host = imp; exports = { }; } { kind = "body"; };
  l = x.link "igloo" proj supply f.value;
  adapter = {
    bindFormals = vals: body: body // { bound = vals; };
    bindArgEnv = vals: { argEnv = vals; };
    wrapFn = fn: { wrapFnOf = fn; };
    wrapUnit = body: units: { inherit body units; };
    interpret = x.interpret;
    thunkBindings = [ "THUNKNAME" ];
  };
  r = x.close "igloo" proj { members = [ ]; } adapter l.value;
in if x.isRefusal r then throw "gen-bind:${r.refusal.code}:${builtins.concatStringsSep "," (r.refusal.witness.unmatched or [ ])}" else "ok"'
check "T5 row20 unplanted (thunkBindings names host, which crosses)" "${row20/THUNKNAME/host}" 0 "" \
  "$tmpdir/row20-green.err" 'ok'
check "T5 row20 planted   (thunkBindings names nope, which never crosses -- ADR-0023(c) site 3)" \
  "${row20/THUNKNAME/nope}" 1 \
  "gen-bind:thunk-bindings-unmatched:nope" \
  "$tmpdir/row20-red.err"

# Row 21 is the SHAPE guard rather than the membership one, and `null` is its unplanted arm on
# purpose: null is the total absent-authorization state the formal admits, so the green arm proves the
# guard admits "no thunks declared" instead of refusing every adapter that omits the key.
row21='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  x0 = gen.lib.substrate.bind.crossing;
  _testHashIdentity = kind: labels: relatumOf:
    builtins.hashString "sha256" (kind + "@" + builtins.concatStringsSep "|" (
      builtins.map (l: l + "=" + relatumOf l) (builtins.sort (a: b: a < b) labels)
    ));
  x = x0 // (x0.mkOperations { hashIdentity = _testHashIdentity; }).value;
  c = x.contractTerm;
  imp = { merge = "one"; contract = c.any; required = true; sealed = false; origin = "fixture"; satisfiedBy = null; };
  supply = { bindings.host = x.binding.plain { value = 1; mark = x.mark.open; }; proposals = { }; origins = { }; };
  proj = (x.registerSupply supply).value.projection;
  f = x.declare { imports.host = imp; exports = { }; } { kind = "body"; };
  l = x.link "igloo" proj supply f.value;
  adapter = {
    bindFormals = vals: body: body // { bound = vals; };
    bindArgEnv = vals: { argEnv = vals; };
    wrapFn = fn: { wrapFnOf = fn; };
    wrapUnit = body: units: { inherit body units; };
    interpret = x.interpret;
    thunkBindings = THUNKSHAPE;
  };
  r = x.close "igloo" proj { members = [ ]; } adapter l.value;
in if x.isRefusal r then throw "gen-bind:${r.refusal.code}:${r.refusal.witness.reason or "NO-REASON"}" else "ok"'
check "T5 row21 unplanted (thunkBindings is null, the total absent-authorization state)" "${row21/THUNKSHAPE/null}" 0 "" \
  "$tmpdir/row21-green.err" 'ok'
check "T5 row21 planted   (thunkBindings is a string, not null or a list -- ADR-0025 item 1)" \
  "${row21/THUNKSHAPE/\"not-a-list\"}" 1 \
  "gen-bind:adapter-malformed:thunkBindings is null or a list of names, not string" \
  "$tmpdir/row21-red.err"
