# `thunk-functor-served-as-its-lambda` — C151, den-hoag-pcfmm. A functor is a function to nixpkgs
# (`lib.isFunction`), and gen-bind resolves a thunk over one exactly as over the lambda it wraps: the
# bare functor and the `setFunctionArgs` functor read the same `bolt` and `config.weft` as the lambda.
# gen-bind read every functor with `builtins.functionArgs` and aborted uncatchably. A `fn` nixpkgs
# reads as no function is refused at `mkThunk`, catchably. The lambda is the control.

{
  asserts,
  genBind,
  hemReads,
  hemPublished,
  hemResolved,
}:

{
  construct = [ "C151" ];
  check = asserts (
    hemResolved [
      hemReads
      { __functor = _: hemReads; }
      hemPublished
    ] == [
      "selvage-tabby"
      "selvage-tabby"
      "selvage-tabby"
    ]
    && !(builtins.tryEval (builtins.seq (genBind.mkThunk { __functor = 5; }) null)).success
  );
}
