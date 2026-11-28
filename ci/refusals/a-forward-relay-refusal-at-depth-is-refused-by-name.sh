# shellcheck shell=bash
# ── a forward relay's refusal at depth is refused BY NAME (ADR-0025 item 1, ADR-0032 ruling 2) ──
# A W1 chain t0 -> .. -> t4096, written in the shape of `forwarded-cell-and-occurrence-relays-deliver-at-depth`'s
# relay: the planted arm places the foot hop (t1 <- t0) at a scope segment that does not exist, and reading the
# deepest target must end in that route's own refusal text, catchably, not in `max-call-depth exceeded`. The
# unplanted arm reads the same chain unplanted to its 4097 spools, so a `forward` that refused every relay
# cannot pass it.
row_a_forward_relay_refusal_at_depth_is_refused_by_name='let
  inputs = (builtins.getFlake (toString ./.)).inputs;
  genDelivery = inputs.gen.lib.framework.delivery;
  lib = inputs.nixpkgs.lib;
  d = 4096;
  tn = i: "t${toString i}";
  hops = builtins.genList (i: i) d;
  hop = i: path: {
    name = "h${toString i}";
    producer = tn i;
    order = [ 0 ];
    site = "gen-demo:${tn i}/h${toString i}";
    from = { class = "c"; node = tn i; select = "cell"; };
    recipe.importsAt = path;
  };
  recv.options.spools = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [ { options.thread = lib.mkOption { type = lib.types.lines; default = ""; }; } ];
    });
    default = { };
  };
  terminals.c = { modules, ... }: (lib.evalModules { modules = [ recv ] ++ modules; }).config.spools;
  projected = {
    nodes = lib.genAttrs (map tn (hops ++ [ d ])) (n: { bindings.node.name = n; classes.c = [ { spools.${n}.thread = n; } ]; });
    occurrenceIds = lib.genAttrs (map tn (hops ++ [ d ])) (_: { c = [ "own" ]; });
  };
  at = foot: (genDelivery.realize { } terminals (genDelivery.forward {
    routes.c = builtins.listToAttrs (map (i: { name = tn (i + 1); value = [ (hop i (if i == 0 then foot else [ ])) ]; }) hops);
  } terminals projected).projected).c.${tn d};
  green = toString (builtins.length (builtins.attrNames (at [ ])));
  planted = at [ { scope = "nope"; } ];
  caught = if (builtins.tryEval (builtins.deepSeq planted true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 a-forward-relay-refusal-at-depth-is-refused-by-name unplanted (the chain reads to all 4097 spools at d = 4096)" \
  "${row_a_forward_relay_refusal_at_depth_is_refused_by_name/BODY/green}" 0 "" \
  "$tmpdir/a-forward-relay-refusal-at-depth-is-refused-by-name-green.err" '4097'
check "T5 a-forward-relay-refusal-at-depth-is-refused-by-name planted   (the foot's placement refusal is raised by name at d = 4096)" \
  "${row_a_forward_relay_refusal_at_depth_is_refused_by_name/BODY/planted}" 1 \
  "gen-delivery: forward: route t0/h0: placement segment { scope = \"nope\"; }: the scope bindings have no 'nope'" \
  "$tmpdir/a-forward-relay-refusal-at-depth-is-refused-by-name-red.err"
check "T5 a-forward-relay-refusal-at-depth-is-refused-by-name catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_a_forward_relay_refusal_at_depth_is_refused_by_name/BODY/caught}" 0 "" \
  "$tmpdir/a-forward-relay-refusal-at-depth-is-refused-by-name-catch.err" 'CAUGHT'
