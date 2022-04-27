{ mkDerivation, array, base, bytestring, containers, criterion
, deepseq, directory, fetchgit, filepath, hedgehog, hpack, hspec
, hspec-hedgehog, lib, mtl, neat-interpolation, process
, profunctors, template-haskell, temporary, text, text-short
, type-errors-pretty, vector
}:
mkDerivation {
  pname = "souffle-haskell";
  version = "3.2.0";
  src = fetchgit {
    url = "https://github.com/luc-tielen/souffle-haskell.git";
    sha256 = "0961gb45hxi4d5y68lnfm011yllvh9p7vik06bppkvz842zsspi0";
    rev = "e38719e612eaf9d8774b5bba44ec5144a721a343";
    fetchSubmodules = true;
  };
  libraryHaskellDepends = [
    array base bytestring containers deepseq directory filepath mtl
    process profunctors template-haskell temporary text text-short
    type-errors-pretty vector
  ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    array base bytestring containers deepseq directory filepath
    hedgehog hspec hspec-hedgehog mtl neat-interpolation process
    profunctors template-haskell temporary text text-short
    type-errors-pretty vector
  ];
  benchmarkHaskellDepends = [
    array base bytestring containers criterion deepseq directory
    filepath mtl process profunctors template-haskell temporary text
    text-short type-errors-pretty vector
  ];
  prePatch = "hpack";
  homepage = "https://github.com/luc-tielen/souffle-haskell#README.md";
  description = "Souffle Datalog bindings for Haskell";
  license = lib.licenses.mit;
}
