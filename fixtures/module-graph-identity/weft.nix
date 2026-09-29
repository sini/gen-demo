# C95 fixture: the other half of a path import cycle (with warp.nix).
{
  imports = [ ./warp.nix ];
  threads = [ "weft" ];
}
