# `boundary-mark-withholds-at-every-one-hop-read` — C191, den-hoag-4or0a U2. `shed` carries a mark
# admitting no label, so its `imports` edge to `heddle` and its `threads` edge to `pick` are withheld
# and every one-hop read from it answers what `resolve { wf = l; }` answers: nothing. `batten`'s mark
# admits `imports` alone, so it reads `heddle` and not `pick`. `reed`, unsealed, reads both.
{
  asserts,
  boundaryOneHop,
}:
{
  construct = [ "boundary-mark-withholds-at-every-one-hop-edge-read" ];
  check = asserts (
    boundaryOneHop "shed" == {
      imports = [ ];
      label = [ ];
      collectImports = [ ];
      collectByLabel = [ ];
      followEdge = [ ];
    }
    &&
      boundaryOneHop "batten" == {
        imports = [ "combed" ];
        label = [ ];
        collectImports = [ "combed" ];
        collectByLabel = [ ];
        followEdge = [ ];
      }
    &&
      boundaryOneHop "reed" == {
        imports = [ "combed" ];
        label = [ "plain" ];
        collectImports = [ "combed" ];
        collectByLabel = [ "plain" ];
        followEdge = [ "pick" ];
      }
  );
}
