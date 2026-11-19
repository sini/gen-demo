{
  title = "an armed reader carries its marker, and the queries branch on it";
  adr = "0008";
  what = "`closed-body-reader`: the body that reads `self.allNodeIds` also reads `self ? reader`, `true` on its armed reader and `false` on an unarmed twin of the same scope evaluated through `genScope.eval`; armed, under a relation declaring the nodes read, `genScope.children` answers `kiln`'s child and `genScope.nodesByType` the `kiln`-kind nodes through the guarded `node` reads, and under the empty relation both are refused while the marker and the enumeration still answer; unarmed, the same helpers answer the same ids through the substrate walk";
}
