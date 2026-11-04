# `fan-out-warm-evaluations-read-their-priors-identity-map` — den-hoag-xrh86 (b). Several warm evaluations
# started from ONE prior over minted instances (`bobbin`s, each declaring `id_hash`) read that prior's
# identity map off the prior, `warmDecision.priorIdentities`, walked once over its own tree, rather than
# re-walking its instances per evaluation. The map is the prior's own identities by path; every sibling
# whose edit moves no identity is served warm, equal to cold; the sibling whose edit moves one is refused,
# and the refusal is its own, so the siblings started after it from the same prior are still served. Red
# if the prior publishes no map or a map that is not its identities, if a sibling is not warm or differs
# from cold, or if the moved identity is served.
{ asserts, genMerge }:
let
  inherit (genMerge) evalModuleTree mkOption mkForce;
  t = genMerge.types;
  inherit (builtins)
    all
    attrNames
    deepSeq
    genList
    listToAttrs
    toJSON
    tryEval
    ;
  bobbin =
    { config, ... }:
    {
      options.id_hash = mkOption { type = t.str; };
      options.spool = mkOption {
        type = t.str;
        default = "";
      };
      config.id_hash = "bobbin:" + builtins.hashString "sha256" config.spool;
    };
  base = [
    {
      options.reel = mkOption { type = t.attrsOf (t.submodule bobbin); };
      options.tag = mkOption {
        type = t.str;
        default = "";
      };
    }
    {
      _file = "reel";
      config.reel = listToAttrs (
        genList (i: {
          name = "b${toString i}";
          value.spool = "s${toString i}";
        }) 8
      );
    }
  ];
  prior = evalModuleTree { } base;
  warmOf =
    edit:
    evalModuleTree {
      warmFrom = prior;
      editedModules = [ edit ];
    } (base ++ [ edit ]);
  coldOf = edit: evalModuleTree { } (base ++ [ edit ]);
  tagOf = k: {
    _file = "tag${toString k}";
    config.tag = "t${toString k}";
  };
  moving = {
    _file = "move";
    config.reel.b3.spool = mkForce "moved";
  };
  served =
    edit:
    let
      w = warmOf edit;
    in
    w.warmDecision.mode == "warm" && toJSON w.config == toJSON (coldOf edit).config;
  refused = edit: !(tryEval (deepSeq (warmOf edit).config true)).success;
  identities = listToAttrs (
    map (n: {
      name = "reel.${n}";
      value = prior.config.reel.${n}.id_hash;
    }) (attrNames prior.config.reel)
  );
in
{
  construct = [ "fan-out-warm-evaluations-read-their-priors-identity-map" ];
  check = asserts (
    prior.warmDecision ? priorIdentities
    && prior.warmDecision.priorIdentities == identities
    && all served (genList tagOf 2)
    && refused moving
    && all served (genList (k: tagOf (k + 2)) 2)
  );
}
