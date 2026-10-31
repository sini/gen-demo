# shellcheck shell=bash
# ── one-host-of-n -- content with no terminal at the LAST host of a fleet is refused BY NAME on
#    ANOTHER host's read (den-hoag-ien5k; ADR-0028's Rider) ──
# The key set is content-decided, so `realize`'s content check reads every node's class set at the
# realization's root: a read of `spindle0` alone still refuses `spindle15`'s `gusset` content, which no
# terminal realizes. The unplanted arm reads the same value and asserts it (`spindle0`'s hostName), so
# a fleet that refused every read cannot pass it.
row_one_host_of_n='let
  demo = builtins.getFlake (toString ./.);
  fleet = import ./fixtures/one-host-of-n { inherit (demo) inputs; };
  names = builtins.genList (k: "spindle" + toString k) 16;
  read = plant: (fleet { inherit names plant; }).spindle0.config.networking.hostName;
in BODY'
check "T5 one-host-of-n unplanted (spindle0 reads its own hostName in a fleet of 16)" \
  "${row_one_host_of_n/BODY/read false}" 0 "" "$tmpdir/one-host-of-n-green.err" 'spindle0'
check "T5 one-host-of-n planted   (spindle15's content with no terminal is refused by name on spindle0's read)" \
  "${row_one_host_of_n/BODY/read true}" 1 \
  "node spindle15 carries declared gusset content, and class gusset has no terminal" "$tmpdir/one-host-of-n-red.err"
