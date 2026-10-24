# `a-type-refusing-a-callers-base-module-arg` — den-hoag-58bib β, gen-merge's limb. A `refusingSubmodule`
# stating `config` refuses a caller's `config` at its `withArgs` and at a redeclaration in either order,
# and serves `argand` on the same two routes. Red if the facility is missing, if any route serves the
# stated key, or if the refusal swallowed the fresh key with it.
{ asserts, refusingTypeArms }:
{
  construct = [ "a-type-refusing-a-callers-base-module-arg" ];
  check = asserts (
    refusingTypeArms == {
      stated = [ "config" ];
      twinStatesNone = true;
      mintsApart = true;
      withArgsRefused = true;
      redeclarationRefused = true;
      redeclarationReversedRefused = true;
      withArgsServesArgand = 2;
      redeclarationServesArgand = 2;
    }
  );
}
