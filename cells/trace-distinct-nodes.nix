# `trace-distinct-nodes` — C98, den-hoag-g1qy0. Distinct nodes stay distinct in every record the
# trace cluster keeps; only a display may render two alike. A derivation standing where a scope name
# belongs is Nix-distinct from the store path it coerces to. The fingerprint refuses it where the
# entry is minted, and the sort key refuses it by name over a hand-built entry, where it used to
# answer the store path's key. The rendering discloses it as `‹set›` rather than the store path it
# used to print, and renders the store path's string as that string. Two entries differing only in
# distance share one sort key and separate in the fingerprint, which is the coincidence the key is
# allowed.
#
# Live control: the genuine trace fingerprints, and the store path's string keys and renders.
{
  asserts,
  diamondMoved,
  genView,
  pkgs,
}:
{
  construct = [ "C98" ];
  check = asserts (
    let
      placement = genView.placement.place {
        mode = "merge";
        path = [ "selvage" ];
        name = "selvage";
        inherit (diamondMoved) value;
      };
      held = x: builtins.tryEval (builtins.deepSeq x x);
      fingerprint = relation: genView.hashTrace { inherit relation placement; };
      c0 = builtins.head diamondMoved.contributions;
      e0 = genView.traceEntryOf {
        contribution = c0;
        inherit placement;
      };
      withSourceScope =
        scope:
        e0
        // {
          source = e0.source // {
            inherit scope;
          };
        };
      storePath = "${pkgs.hello}";
      renderedDerivation = genView.renderEntry (withSourceScope pkgs.hello);
      renderedString = genView.renderEntry (withSourceScope storePath);
      farther = diamondMoved // {
        contributions = [ (c0 // { distance = c0.distance + 1; }) ];
      };
    in
    # the genuine trace fingerprints, and a store path's string keys as a scope name
    (held (fingerprint diamondMoved)).success
    && (held (genView.edgeSortKey (withSourceScope storePath))).success
    # a derivation where a scope belongs is refused, never keyed as its store path
    && !(held (
      fingerprint (
        diamondMoved
        // {
          contributions = map (c: c // { scope = pkgs.hello; }) diamondMoved.contributions;
        }
      )
    )).success
    && !(held (genView.edgeSortKey (withSourceScope pkgs.hello))).success
    # the rendering discloses the derivation by type and prints the string as itself: the two
    # renderings differ, and exactly at the marker
    && renderedDerivation != renderedString
    &&
      builtins.replaceStrings [ "‹set›" ] [ (builtins.toJSON storePath) ] renderedDerivation
      == renderedString
    # the one coincidence a sort key is allowed: one key, two fingerprints
    && genView.edgeSortKey e0 == genView.edgeSortKey (e0 // { distance = e0.distance + 1; })
    && fingerprint diamondMoved != fingerprint farther
  );
}
