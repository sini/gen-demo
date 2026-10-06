# ── C151 — a thunk's `fn` is read as nixpkgs reads a function (den-hoag-pcfmm). The same hem, read
# from `bolt` and `config.weft`, three ways: a lambda, a bare functor over it, and a `setFunctionArgs`
# functor whose formals live only in its published `__functionArgs`. gen-bind resolves each against
# one `ctx` and one `config`.
{ lib, genBind }:
{
  hemReads = { bolt, config, ... }: "${bolt}-${config.weft}";
  hemPublished = lib.setFunctionArgs (a: "${a.bolt}-${a.config.weft}") {
    bolt = false;
    config = false;
  };
  hemResolved =
    fns:
    (genBind.resolveThunks { } {
      config.weft = "tabby";
      ctx.bolt = "selvage";
      thunkArgNames = [ "hem" ];
      bindings.hem = map genBind.mkThunk fns;
    }).hem;
}
