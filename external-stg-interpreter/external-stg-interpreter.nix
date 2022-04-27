{ mkDerivation, base, bytestring, containers, directory
, external-stg, filepath, gomp, hspec, hspec-core, hspec-discover
, inline-c, lib, libffi, mtl, optparse-applicative, pretty-terminal
, primitive, QuickCheck, souffle-haskell, text, time, unagi-chan
, unix, vector
}:
mkDerivation {
  pname = "external-stg-interpreter";
  version = "0.1.0.1";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base bytestring containers directory external-stg filepath inline-c
    libffi mtl pretty-terminal primitive souffle-haskell text time
    unagi-chan unix vector
  ];
  librarySystemDepends = [ gomp ];
  executableHaskellDepends = [
    base bytestring containers external-stg optparse-applicative
    unagi-chan unix
  ];
  testHaskellDepends = [
    base external-stg hspec hspec-core hspec-discover mtl QuickCheck
  ];
  testToolDepends = [ hspec-discover ];
  description = "External STG interpreter";
  license = lib.licenses.bsd3;
}
