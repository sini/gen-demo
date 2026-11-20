# shellcheck shell=bash
# ── a forward route carrying an undeclared key is refused BY NAME, with the route (den-hoag-lrnaw;
#    ADR-0025 item 1) ──
# A resolved-form route is a closed record: `forward` reads a fixed key set, and any other key, a
# closure `guard` here, refuses with gen-prelude's shared `unknownOption` text rather than delivering
# unconditionally. The route is written in the shape of `forwarded-occurrence-reaches-a-nested-receiver`'s
# `route` helper, which takes no extra key, so the plant is `route // { guard = …; }`. The unplanted
# arm asserts the delivered thread, so a `forward` that refused every route cannot pass it.
row_a_forward_route_carrying_an_undeclared_key_is_refused_by_name='let
  inputs = (builtins.getFlake (toString ./.)).inputs;
  genDelivery = inputs.gen.lib.framework.delivery;
  lib = inputs.nixpkgs.lib;
  route = {
    name = "g";
    producer = "damask";
    order = [ 0 ];
    site = "gen-demo:damask/g";
    from = { class = "sett"; node = "damask"; select = "declared"; };
    recipe.importsAt = [ "spools" { dest = "name"; } ];
  };
  recv.options.spools = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submoduleWith {
      shorthandOnlyDefinesConfig = true;
      modules = [ { options.thread = lib.mkOption { type = lib.types.lines; default = ""; }; } ];
    });
    default = { };
  };
  terminals = {
    weft = { modules, ... }: (lib.evalModules { modules = [ recv ] ++ modules; }).config.spools.pewter.thread;
    sett = _: null;
  };
  projected = {
    nodes.pewter = { bindings.node.name = "pewter"; classes.weft = [ { spools.pewter.thread = "R"; } ]; };
    nodes.damask = { bindings.node.name = "damask"; classes.sett = [ { thread = "A"; } ]; };
    occurrenceIds = { pewter.weft = [ "pewter" ]; damask.sett = [ "damask" ]; };
  };
  at = r: (genDelivery.realize { } terminals (genDelivery.forward { routes.weft.pewter = [ r ]; } terminals projected).projected).weft.pewter;
  green = builtins.toJSON (at route);
  planted = at (route // { guard = _: false; });
  caught = if (builtins.tryEval (builtins.deepSeq planted true)).success then "ADMITTED" else "CAUGHT";
in BODY'
check "T5 a-forward-route-carrying-an-undeclared-key-is-refused-by-name unplanted (a route with only declared keys delivers)" \
  "${row_a_forward_route_carrying_an_undeclared_key_is_refused_by_name/BODY/green}" 0 "" \
  "$tmpdir/a-forward-route-carrying-an-undeclared-key-is-refused-by-name-green.err" '"A\nR"'
check "T5 a-forward-route-carrying-an-undeclared-key-is-refused-by-name planted   (a route carrying a guard is refused by name, with the route)" \
  "${row_a_forward_route_carrying_an_undeclared_key_is_refused_by_name/BODY/planted}" 1 \
  "gen-delivery: forward: route into weft.pewter: damask/g: 'guard' is not an option of this door; the options are closed (accepted: 'from', 'name', 'order', 'producer', 'recipe', 'required', 'site')" \
  "$tmpdir/a-forward-route-carrying-an-undeclared-key-is-refused-by-name-red.err"
check "T5 a-forward-route-carrying-an-undeclared-key-is-refused-by-name catchable  (the refusal is caught by tryEval, not an abort)" \
  "${row_a_forward_route_carrying_an_undeclared_key_is_refused_by_name/BODY/caught}" 0 "" \
  "$tmpdir/a-forward-route-carrying-an-undeclared-key-is-refused-by-name-catch.err" 'CAUGHT'
