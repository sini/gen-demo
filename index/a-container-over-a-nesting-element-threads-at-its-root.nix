{
  title = "a container over a nesting element still threads at its root, while a leaf chain is not walked";
  adr = "0032 (den-hoag-c922w)";
  what = "`container-over-a-nesting-element-threads-at-its-root`: an option root reads by presence whether a container's element chain ends at a leaf; an `attrsOf (listOf submodule)`, a `listOf submodule` and an `attrsOf (nullOr submodule)` still thread there and serve each element's configuration with its defaults filled in, and an `attrsOf (listOf (nullOr int))` beside them is served as merged";
}
