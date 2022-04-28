{ mkDerivation, base, bytestring, filepath, lib
, optparse-applicative, zip
}:
mkDerivation {
  pname = "mod-pak";
  version = "0.1.0.1";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base bytestring filepath optparse-applicative zip
  ];
  description = "A library organize compiled haskell module metadata";
  license = lib.licenses.bsd3;
}
