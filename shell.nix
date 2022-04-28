import (./ghc.nix.wpc/default.nix) {
  useClang = true;
  withHadrianDeps = true;
  withIde   = false;
  withLlvm  = true;
}
