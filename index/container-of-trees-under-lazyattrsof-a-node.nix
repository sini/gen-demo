{
  title = "a container of trees under `lazyAttrsOf`, a node";
  adr = "0012, 0033";
  what = "`lazy-container-node`: `o` is `lazyAttrsOf (attrsOf submodule)`; `o.foo.a.x = 1` reads `1` and `o.foo.a.n` reads `a` while `o.bar` is a `throw`, never read: the lazy position is a container node that keys its own trees over its own definitions only (S1 class (a), arm (v))";
}
