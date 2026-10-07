# `lappetKnob` — instance-names-deciding-their-kind-compose-on-both-constructs, den-hoag-2vo1m. Both constructs
# answer both composing knob shapes with the same instance. Red: a registry whose name set is read off
# its apply pipeline aborts the `byNames` arm uncatchably, which reds the whole check evaluation.
{ asserts, lappetKnob }:
let
  plain = {
    nap = "plush";
    weft = null;
  };
  woven = {
    nap = "plush";
    weft = "woven";
  };
  expected = {
    off = plain;
    on = woven;
    byNames = woven;
  };
in
{
  construct = [ "instance-names-deciding-their-kind-compose-on-both-constructs" ];
  check = asserts (lappetKnob.registry == expected && lappetKnob.sibling == expected);
}
