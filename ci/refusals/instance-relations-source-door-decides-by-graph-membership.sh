# shellcheck shell=bash
# ── row 156 -- the instance relation's source door decides by graph membership, BY NAME
#    (mirrors C136's `aspect-instance-identity`; den-hoag-fkkzk, owner-ruled arm (d)) ──
# A framework names its own entity kinds (ADR-0035), so a `loom` supplied by an entity whose kind
# this framework spells `aspect` is an ordinary source: the unplanted arm mints `gauge` at it. The
# plant hands `gauge`'s own node id as the source instead: a node of the relation's own graph
# supplies no argument, and only membership tells the two apart, since both ids carry the tag
# `aspect`. A door that refused by spelling fails the unplanted arm; one that admitted every id
# fails the planted one.
row_instance_relations_source_door_decides_by_graph_membership='let
  gen = (builtins.getFlake (toString ./.)).inputs.gen;
  genAspects = gen.lib.aspects.aspects;
  genMerge = gen.lib.modules.merge;
  hashIdentity = gen.lib.substrate.identity.hashIdentity;
  cnf = import ./aspect-cnf.nix // { entityKinds = { loom = true; }; };
  t = (gen.lib.substrate.algebra.term hashIdentity).term;
  inherit (genAspects) guard pred;
  aspects = (genMerge.evalModuleTree { } [

    { options.aspects = (genAspects.mkAspectSchema cnf).mkAspectOption { }; }

    { aspects = {
        frame.includes = [ "gauge" ];
        gauge = guard (pred.has "loom") { description = t.concat [ (t.lit "gauge-") (t.readCtx "loom" [ ]) ]; };
      }; }

  ]).config.aspects;
  facet = hashIdentity "aspect" [ "name" ] (_: "jacquard");
  gaugeId = genAspects.aspectId [ ] (genAspects.graphFacts cnf aspects).nodeData.gauge;
  rel = src: genAspects.instancesFor cnf aspects {
    suppliers.${src}.loom = "jacquard";
    containment = { };
    scopes.warp = { members = [ "frame" ]; sources.loom = src; };
  };
  vertexOf = src: builtins.head (builtins.attrValues (rel src).vertices);
  green = builtins.toJSON {
    tags = map (s: builtins.head (builtins.split ":" s)) [ facet gaugeId ];
    sourced = (vertexOf facet).formals.loom == facet;
    inherit ((vertexOf facet).entry) description;
  };
  planted = builtins.toJSON (vertexOf gaugeId).formals;
in BODY'
check "T5 instance-relations-source-door-decides-by-graph-membership unplanted (a framework entity kind spelled aspect supplies loom)" \
  "${row_instance_relations_source_door_decides_by_graph_membership/BODY/green}" 0 "" "$tmpdir/instance-relations-source-door-decides-by-graph-membership-green.err" \
  '{"description":"gauge-jacquard","sourced":true,"tags":["aspect","aspect"]}'
check "T5 instance-relations-source-door-decides-by-graph-membership planted   (gauge's own node id as the source is refused by name)" \
  "${row_instance_relations_source_door_decides_by_graph_membership/BODY/planted}" 1 \
  "the identity of a node of this relation's own graph, which supplies no argument" \
  "$tmpdir/instance-relations-source-door-decides-by-graph-membership-door.err"
