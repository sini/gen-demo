# ── C118 — one projection realizes on two pins through the delivery-class map (ADR-0028;
# den-hoag-htfv3). Deliberately OUTSIDE `config.gen.composed`, the way C22 is: its own invented
# nodes and its own declaration. One authored class, `couching`, carried by one aspect that all
# three nodes list. `project`'s `deliveryClasses` sends `godet` and `jabot` (pin `batiste`) to
# `couching-batiste` and `ruffle` (pin `organza`) to `couching-organza`; no terminal is named
# `couching`. Each delivery class's terminal is the REAL gen-bind `mkHostedTerminal` over stock
# nixpkgs `lib.evalModules`, stamping its own pin, and its target reads its peers through `nodes`.
{
  lib,
  genAspects,
  genMerge,
  genScope,
  genBind,
  genDelivery,
}:
let
  couchingCnf.keySemantics.couching.category = "class";
  couchingValues =
    (genMerge.evalModuleTree { } [
      ((genAspects.mkAspectSchema couchingCnf).mkAspectModule { })
      { aspects.braid.couching.stitches = [ "braid" ]; }
    ]).config;
  couchingNodes = {
    godet.aspects = [ "braid" ];
    jabot.aspects = [ "braid" ];
    ruffle.aspects = [ "braid" ];
  };
  couchingPinMap = {
    godet.couching = "couching-batiste";
    jabot.couching = "couching-batiste";
    ruffle.couching = "couching-organza";
  };
  couchingProjectionOf =
    deliveryClasses:
    genDelivery.project {
      values = couchingValues;
      cnf = couchingCnf;
      selectNodes = _: couchingNodes;
      inherit deliveryClasses;
    };

  # The pin enters the evaluation as the terminal's own module; the peer set is what
  # `mkHostedTerminal` hands the target as `nodes`, so `peers` is read inside the target.
  couchingTerminalFor =
    class: pin: carriage:
    let
      a =
        (genBind.crossing.mkHostedTerminal {
          evaluator = args: lib.evalModules { inherit (args) modules specialArgs; };
          locateConfig = ev: ev.config;
          inherit class;
        }).adapter
          {
            inherit (carriage) extent extraModules;
            peersOf = _id: builtins.attrNames carriage.extent;
            engine = genScope;
            marksOf = _id: [ ];
            readerId = carriage.name;
          };
      ev = a.wrapUnit (a.bindFormals carriage.bindings (
        carriage.modules
        ++ [
          (
            { nodes, ... }:
            {
              options.stitches = lib.mkOption { type = lib.types.listOf lib.types.str; };
              options.pin = lib.mkOption { type = lib.types.str; };
              options.peers = lib.mkOption { type = lib.types.listOf lib.types.str; };
              options.warnings = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              config.pin = pin;
              config.peers = builtins.attrNames nodes;
            }
          )
        ]
      )) [ ];
    in
    {
      inherit (ev.config) stitches pin peers;
    };
  couchingTerminals = {
    couching-batiste = couchingTerminalFor "couching-batiste" "batiste";
    couching-organza = couchingTerminalFor "couching-organza" "organza";
  };
in
{
  inherit couchingPinMap couchingProjectionOf couchingTerminals;
  couchingRealized = genDelivery.realize {
    projected = couchingProjectionOf couchingPinMap;
    terminals = couchingTerminals;
  };
  # `ruffle` has no entry, so its content stays under `couching`, which has no terminal.
  couchingMissingRealized = genDelivery.realize {
    projected = couchingProjectionOf (builtins.removeAttrs couchingPinMap [ "ruffle" ]);
    terminals = couchingTerminals;
  };
}
