# C95 fixture: one half of a path import cycle (with weft.nix).
{
  imports = [ ./weft.nix ];
  threads = [ "warp" ];
}
