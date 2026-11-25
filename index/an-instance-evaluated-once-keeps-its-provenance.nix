{
  title = "an instance evaluated once keeps its provenance";
  adr = "0039 (den-hoag-t5ndo)";
  what = "`an-instance-evaluated-once-keeps-its-provenance`: gen-schema `mkInstancePaired` (gen-merge `refusingSubmodulePaired`) returns `{ type; evaluate; }` from one construction; `evaluate loc defs` is one evaluation returning `{ config; provenance; }`, whose `config` is the typed merge's and `mkInstanceType`'s on the same inputs, whose provenance names each definition's file, which refuses a definition outside the domain on both projections, and whose `type`'s derivations carry no evaluator";
}
