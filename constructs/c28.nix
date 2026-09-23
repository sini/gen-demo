# ── C28 — the order mark BINDS against a declaration that declines it (ADR-0026, M9) ──
#
# The effective visibility order is the LEXICOGRAPHIC PRODUCT of a declared order mark with
# the declaration's own order, MARK OUTER: `a <ₑ b ⟺ a <ₘ b ∨ (a ≃ₘ b ∧ a <q b)`. A
# declaration may therefore refine only INSIDE the mark's ties, and can neither erase nor
# reverse a pair the mark states — which is what lets an authority bind a query written to
# ignore it, with no ecosystem-wide `L̂` ever minted.
#
# ★★ THE FIXTURE IS THE CORPUS'S OWN GRAPH, AND IT IS THE DECLINE CASE. `pewter` reaches
# `grosgrain` on the real `tacks` edge and `damask` on the real `gathers` edge — both rows of
# `declaredEdges`, read through C2's own `byLabel` accessor rather than restated — and every
# datum below is a value the corpus really declares at that node. The query order is written
# to DECLINE: `gathers` outranks `tacks`, and `$ = -1` puts the root's own empty path below
# both arrivals, so `pewter` keeps its own value and NEITHER arrival is visible. That decline
# is what the mark has to overcome; a neutral query would let a mark "win" against nothing.
#
# ★ ADMISSION IS ONE OPTIONAL STEP (`(tacks|gathers)?`), AND THE `?` IS THE LOAD-BEARING
# HALF: it admits the ROOT'S OWN EMPTY PATH, without which `pewter` cannot decline at all.
# Measured on this fixture, dropping the `?` moves the unmarked arm off `pewter`'s own
# `linen` and onto `damask`'s `sateen` — the query merely PREFERRING `gathers` to `tacks`,
# which a mark would overcome without ever facing a target that kept its own value. The `*`
# form answers identically to `?` here and is NOT what buys the decline: `damask`'s second
# arrival along `tacks·tacks` collapses onto its `gathers` arrival at the same ⟨node,
# residual-state⟩, which is C4b's subject and not this cell's.
{
  byLabel,
  genValues,
  genView,
  identityMark,
  nodes,
}:
let
  mandateLabels = genView.edgeLabels {
    letters = [
      "tacks"
      "gathers"
    ];
  };
  mandateAdmission = genView.labelWellFormedness {
    alphabet = mandateLabels;
    expression = "(tacks|gathers)?";
  };
  mandateOrder =
    spec:
    genView.labelOrder {
      alphabet = mandateLabels;
      inherit (spec) layers endOfPath;
    };
  # THE DECLINE. `$` below every letter, so the root's own path beats both arrivals.
  mandateDeclineOrder = {
    layers = [
      [ "gathers" ]
      [ "tacks" ]
    ];
    endOfPath = -1;
  };
  # THE MARK. `tacks` outranks `$` outranks `gathers` — the empty layer is how a rank belonging
  # to `$` alone is written down in a declaration made of letters.
  mandateBindingMark = {
    layers = [
      [ "tacks" ]
      [ ]
      [ "gathers" ]
    ];
    endOfPath = 1;
  };
  mandateCarrier = genView.carrier {
    labels = mandateLabels;
    relations = genView.relations { names = [ "gimp" ]; };
    relatumLabels = genView.relatumLabels { names = [ ]; };
    labelWellFormedness = mandateAdmission;
    labelOrder = mandateOrder mandateDeclineOrder;
    dataOrder = genView.dataOrder {
      channel = "selvage";
      keyOf = _: "selvage";
    };
  };
  mandateGraph = genView.scopeGraph {
    carrier = mandateCarrier;
    scopes = builtins.attrNames nodes;
    # C2's own accessor over the one graph, so a corpus edge that moved moves this walk too.
    edges = {
      tacks = byLabel "tacks";
      gathers = byLabel "gathers";
    };
    # The corpus's real declared content at each of the three scopes in play, read off the
    # registries. A restated literal here would make the cell a statement about this block.
    data = [
      {
        scope = "pewter";
        relation = "gimp";
        datum = [ genValues.thimbles.pewter.spool ];
      }
      {
        scope = "grosgrain";
        relation = "gimp";
        datum = [ genValues.bobbins.grosgrain.gauge ];
      }
      {
        scope = "damask";
        relation = "gimp";
        datum = [ genValues.thimbles.damask.spool ];
      }
    ];
  };
  # ONE call, varying ONLY the mark. Everything else — definition, graph, marks — is shared, so
  # the difference between the two arms below is the mark and can be nothing else.
  mandateUnder =
    mark:
    genView.viewRelation {
      definition = genView.compositions.movement {
        channel = "selvage";
        relation = "gimp";
        root = "pewter";
        direction = "outbound";
        admission = mandateAdmission;
        order = mandateOrder mandateDeclineOrder;
        wellFormed = _: true;
        empty = [ ];
        tieSet = genView.tieSets.union;
        combine = genView.combines.listAppend;
        dedup = genView.dedups.none;
      };
      marks = _: [ ];
      orderMark = mark;
      graph = mandateGraph;
    };
  # THE MANDATE BINDS: `tacks` is outermost, so `grosgrain`'s arrival beats the root's decline.
  mandateBound = mandateUnder (mandateOrder mandateBindingMark);
  # THE CONTROL: the identity mark, under which the product degenerates and the declaration's
  # own order decides alone — the decline stands and the root keeps its own value.
  mandateDeclined = mandateUnder (identityMark mandateLabels);
in
{
  inherit
    mandateLabels
    mandateAdmission
    mandateOrder
    mandateDeclineOrder
    mandateBindingMark
    mandateCarrier
    mandateGraph
    mandateUnder
    mandateBound
    mandateDeclined
    ;
}
