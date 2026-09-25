# shellcheck shell=bash
# ── row 71 -- den-hoag-fbyd3's relatum guard at gen-bind's crossing door. A crossing's relata are
# references (strings); a record in the target position -- a node record, say -- is refused as a
# value, `relatum-not-reference`, blaming the caller, rather than minted over. The plant goes through
# `link`, whose target reaches the mint via `nodeFor`, and carries the test-only `_testHashIdentity`
# stand-in exactly as rows 20/21 do. The unplanted arm links the string target `"igloo"`, so a door
# that refused everything cannot pass by exiting 0.
row71='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  x0 = gen.lib.substrate.bind.crossing;
  _testHashIdentity = kind: labels: relatumOf:
    builtins.hashString "sha256" (kind + "@" + builtins.concatStringsSep "|" (
      builtins.map (l: l + "=" + builtins.toJSON (relatumOf l)) (builtins.sort (a: b: a < b) labels)
    ));
  x = x0 // (x0.mkOperations { hashIdentity = _testHashIdentity; }).value;
  c = x.contractTerm;
  imp = { merge = "one"; contract = c.any; required = true; sealed = false; origin = "fixture"; satisfiedBy = null; };
  supply = { bindings.host = x.binding.plain { value = 1; mark = x.mark.open; }; proposals = { }; origins = { }; };
  proj = (x.registerSupply supply).value.projection;
  f = x.declare { imports.host = imp; exports = { }; } { kind = "body"; };
  l = x.link TARGET proj supply f.value;
in if x.isRefusal l then throw "gen-bind:${l.refusal.code}:${l.refusal.witness.label or "NO-LABEL"}" else builtins.seq (builtins.deepSeq l.value.crossings null) "ok"'
row71str='"igloo"'
row71rec='{ identity = "thimble:x"; }'
check "T5 row71 unplanted (link target is the string igloo, a reference)" "${row71/TARGET/$row71str}" 0 "" \
  "$tmpdir/row71-green.err" 'ok'
check "T5 row71 planted   (link target is a record, not a reference -- den-hoag-fbyd3)" \
  "${row71/TARGET/$row71rec}" 1 \
  "gen-bind:relatum-not-reference:target" \
  "$tmpdir/row71-red.err"
