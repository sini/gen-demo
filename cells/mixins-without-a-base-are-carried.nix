# `mixins-without-a-base-are-carried`. Red at gen-schema 2f3a0a2: a `null` base ran no mixin pipeline,
# so `pub` was `[ "own" ]`, `mxo` was not an option and the instance had no `mxo`; the function-module
# base was served silently, the mixin dropped.
{ asserts, mwbRead }:
{
  construct = [ "mixins-without-a-base-are-carried" ];
  check = asserts (
    mwbRead == {
      pub = [
        "own"
        "mx"
      ];
      opt = true;
      inst = "m";
      fnBaseServed = false;
    }
  );
}
