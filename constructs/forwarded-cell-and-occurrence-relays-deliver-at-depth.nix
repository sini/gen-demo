# ── forwarded-cell-and-occurrence-relays-deliver-at-depth (ADR-0032 ruling 2, ADR-0025 item 1; gen-delivery
# `forward`) ──
# Invented nodes `t0 .. t4096` over the REAL `genDelivery.forward` and `genDelivery.realize`. Each `t<i>` owns one
# spool, `spools.t<i>`, in class `c`, whose terminal is an attrsOf-submodule receiver. Three relays, each 4096 hops
# deep, each read at its deepest target:
# - a W1 chain: `t<i+1>` receives `t<i>`'s whole cell (`select = "cell"`), so `t4096` holds all 4097 spools;
# - a twin ladder: `t<i+1>` receives `t<i>`'s cell by TWO routes, producers `a` and `b` (a merge at every level),
#   so `t4096` holds the same 4097;
# - an occurrence relay: `t1` receives `t0`'s cell, and every `t<i+1>` above receives only `t0`'s occurrence `own`
#   from `t<i>`, so `t4096` holds two spools, `t0` and its own.
# `forward` fills each target's carriage memos source first, so a read costs a constant stack depth however deep
# the relay. Before that, these reads aborted with `max-call-depth exceeded`, a refusal `tryEval` cannot catch.
{ genDelivery, lib }:
let
  inherit (lib) mkOption types;
  d = 4096;
  tn = i: "t${toString i}";
  route =
    {
      name,
      node,
      # a route is named `<producer>/<name>` in a refusal; each hop's producer is its source cell
      producer ? node,
      order ? [ 0 ],
      select ? "cell",
    }:
    {
      inherit name producer order;
      site = "gen-demo:${producer}/${name}";
      from = {
        class = "c";
        inherit node select;
      };
      recipe.importsAt = [ ];
    };
  recv = {
    options.spools = mkOption {
      type = types.attrsOf (
        types.submoduleWith {
          shorthandOnlyDefinesConfig = true;
          modules = [
            {
              options.thread = mkOption {
                type = types.lines;
                default = "";
              };
            }
          ];
        }
      );
      default = { };
    };
  };
  terminals.c = { modules, ... }: (lib.evalModules { modules = [ recv ] ++ modules; }).config.spools;
  hops = builtins.genList (i: i) d;
  projected = {
    nodes = lib.genAttrs (map tn (hops ++ [ d ])) (n: {
      bindings.node.name = n;
      classes.c = [ { spools.${n}.thread = n; } ];
    });
    occurrenceIds = lib.genAttrs (map tn (hops ++ [ d ])) (_: {
      c = [ "own" ];
    });
  };
  relay =
    routes:
    (genDelivery.realize { } terminals
      (genDelivery.forward { routes.c = routes; } terminals projected).projected
    ).c.${tn d};
  upward =
    f:
    builtins.listToAttrs (
      map (i: {
        name = tn (i + 1);
        value = f i;
      }) hops
    );
in
{
  relaysAtDepth = {
    inherit d;
    chain = relay (
      upward (i: [
        (route {
          name = "h${toString i}";
          node = tn i;
        })
      ])
    );
    ladder = relay (
      upward (i: [
        (route {
          name = "a${toString i}";
          producer = "a";
          node = tn i;
        })
        (route {
          name = "b${toString i}";
          producer = "b";
          order = [ 1 ];
          node = tn i;
        })
      ])
    );
    occurrence = relay (
      upward (
        i:
        if i == 0 then
          [
            (route {
              name = "h0";
              node = "t0";
            })
          ]
        else
          [
            (route {
              name = "q${toString i}";
              node = tn i;
              select.occurrence = {
                node = "t0";
                class = "c";
                id = "own";
              };
            })
          ]
      )
    );
  };
}
