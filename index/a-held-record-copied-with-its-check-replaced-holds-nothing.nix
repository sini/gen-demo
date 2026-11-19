{
  title = "a held record copied with its check replaced holds nothing";
  adr = "0020";
  what = "`a-held-record-copied-with-its-check-replaced-holds-nothing`: `x` and `y` each declare `listOf int` beside a nixpkgs `listOf`, and declared together their element is a held record `z` stating it holds `x`'s element `px`; `[ 0 ]` is refused together on both engines; a `//` copy of `z` with its check replaced, and one keeping check and fold but stating a v2 `merge`, each hold nothing, so `px` beside either refuses `[ 0 ]` on gen's engine; one container redeclared N times beside a foreign one serves `[ 2 ]` and refuses `[ 0 ]` at N = 2, 4 and 8";
}
