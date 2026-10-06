{
  title = "a thunk's `fn` is read as nixpkgs reads a function";
  adr = "0025 item 1, pcfmm";
  what = "`thunk-functor-served-as-its-lambda`: gen-bind's `resolveThunks` serves a hem thunk whose `fn` is a bare functor over a `{ bolt, config, ... }:` lambda, or a `setFunctionArgs` functor whose formals live only in its published `__functionArgs`, the value it serves the lambda (`selvage-tabby`), where gen-bind read each with `builtins.functionArgs` and aborted uncatchably; `mkThunk` refuses `{ __functor = 5; }`, which nixpkgs reads as no function, catchably; the lambda is the control";
}
