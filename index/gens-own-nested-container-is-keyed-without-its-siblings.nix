{
  title = "gen's own nested container is keyed without its siblings";
  adr = "0025 item 1, mda6f";
  what = "`nested-container-keyed-on-read`: gen's `attrsOf`/`listOf` of `attrsOf`/`listOf` of a gen `submodule`, and two and three deep through `nullOr` and a stock `attrsOf`, read beside a sibling outside the inner container's domain, a sibling whose element throws, and a `mkIf false` sibling element, each equal to nixpkgs' value over its own types";
}
