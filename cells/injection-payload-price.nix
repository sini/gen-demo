# `injection-payload-price` — C24, den-hoag-9ivu. ADR-0023 (b)'s declared interim, read from the
# side that pays for it. gen-bind's `injectAdapter` states that substrate-built values carrying
# genuine functions cross into the target's `_module.args`, inert only because the consuming module
# system never type-walks that position; this cell is the consumer confirming it on its OWN composed
# values — gen-schema's `__functor` crosses and is still applicable here, plain data crosses
# verbatim, and a substrate-written data position is plain, which is the control that stops the
# first arm passing for the wrong reason. Sites 1 and 4 of the same interim are not declarable in
# any corpus: their own text records that no shipped Adapter reaches them.
#
# C24 — ADR-0023 (b)'s interim price, read by the consumer that pays it
# (den-hoag-9ivu). Four arms, and the first two are a matched pair so neither can
# pass for the wrong reason: the crossed payload is NOT all-plain at a position the
# SUBSTRATE writes (`schema.thimble` carries gen-schema's own `__functor`), while a
# position the substrate writes as data IS plain (`thimbles.pewter`) — a predicate
# that called everything impure would satisfy the first arm alone.
# The remaining two are the crossing itself: plain data arrives verbatim, and the
# closure arrives EXECUTABLE — applying it inside this evaluation is the price's own
# words ("a substrate closure executes in the target"), not an inference from a type.
# RED (what this cell exists to catch): the interim ending unannounced. If site 5
# ever narrows to provably-plain-data — ADR-0023 (c), den-hoag-i546n — the closure
# stops crossing and this cell reds, which is the corpus noticing that the declared
# opt-out it records is no longer the system's behaviour.
{
  asserts,
  c24Crossed,
  c24Payload,
  c24PlainAt,
}:
{
  construct = [ "C24" ];
  check = asserts (
    !(c24PlainAt c24Payload.schema.thimble)
    && c24PlainAt c24Payload.thimbles.pewter
    && c24Crossed.declaredEdges == c24Payload.declaredEdges
    && (c24Crossed.schema.thimble { }) ? imports
  );
}
