# `shared-instances-under-the-map` — C186, den-hoag-htfv3 (D3′, D4). Instance content follows C118's
# delivery-class map: `godet` and `jabot` realize under `couching-batiste` (pin `batiste`, peers
# `[godet jabot]`), each with its own `tuck`, whose include names its own pleat, and the one `hem`
# their shared pin supplies; `ruffle` realizes under `couching-organza`. Each realized list reads
# the node's members reversed, the stock list merge's order.
#   D4: what each node delivered is named beside it (`elementIds`). `hem` is ONE id at `godet` and
#   `jabot`, the vertex the relation lists for both; the three `tuck`s are three ids.
{
  asserts,
  sharedEvalRel,
  sharedEvalProjection,
  sharedEvalRealized,
}:
let
  at = pin: peers: stitches: { inherit pin peers stitches; };
  ids = n: dc: sharedEvalProjection.nodes.${n}.elementIds.${dc};
  hemAt = n: builtins.head (ids n "couching-batiste");
  tuckOf = n: builtins.head sharedEvalRel.reaches.${n}.tuck;
in
{
  construct = [ "C186" ];
  check = asserts (
    sharedEvalRealized == {
      couching-batiste = {
        godet =
          at "batiste"
            [
              "godet"
              "jabot"
            ]
            [
              "pleat-godet"
              "braid"
              "tuck"
              "hem"
            ];
        jabot =
          at "batiste"
            [
              "godet"
              "jabot"
            ]
            [
              "pleat-jabot"
              "braid"
              "tuck"
              "hem"
            ];
      };
      couching-organza.ruffle =
        at "organza"
          [ "ruffle" ]
          [
            "pleat-ruffle"
            "braid"
            "tuck"
          ];
    }
    && hemAt "godet" == hemAt "jabot"
    && [ (hemAt "godet") ] == sharedEvalRel.reaches.godet.hem
    &&
      ids "godet" "couching-batiste" == [
        (hemAt "godet")
        (tuckOf "godet")
        "braid"
        "pleat-godet"
      ]
    &&
      ids "jabot" "couching-batiste" == [
        (hemAt "godet")
        (tuckOf "jabot")
        "braid"
        "pleat-jabot"
      ]
    &&
      ids "ruffle" "couching-organza" == [
        (tuckOf "ruffle")
        "braid"
        "pleat-ruffle"
      ]
    &&
      builtins.length (
        builtins.attrNames (
          builtins.groupBy (x: x) (
            map tuckOf [
              "godet"
              "jabot"
              "ruffle"
            ]
          )
        )
      ) == 3
  );
}
