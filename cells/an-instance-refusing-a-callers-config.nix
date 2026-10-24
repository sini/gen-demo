# `an-instance-refusing-a-callers-config` — den-hoag-58bib β, gen-schema's limb. The instance type states
# `config`, `options` and `prefix`; a caller's `config` through its `withArgs` is refused, and `argand`
# through the same `withArgs` reaches the kind's module while the instance keeps its own field and its
# identity. Red if the instance serves the caller's `config` (its kind argument would read the caller's
# set), or if the refusal took `argand` with it.
{ asserts, instanceRefusalArms }:
{
  construct = [ "an-instance-refusing-a-callers-config" ];
  check = asserts (
    instanceRefusalArms == {
      stated = [
        "config"
        "options"
        "prefix"
      ];
      plantedRefused = true;
      servedWhorl = "bead";
      servedYarn = "flax";
      servedIdentity = true;
    }
  );
}
