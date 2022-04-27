{ nixpkgs ? import <nixpkgs> {}, compiler ? "default", doBenchmark ? false }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, aeson, ansi-wl-pprint, base, binary
      , bytestring, containers, directory, exceptions, filemanip
      , filepath, hashable, lib, optparse-applicative, text, transformers
      , unordered-containers, zip
      }:
      mkDerivation {
        pname = "external-stg";
        version = "0.1.0.1";
        src = ./.;
        isLibrary = true;
        isExecutable = true;
        libraryHaskellDepends = [
          aeson ansi-wl-pprint base binary bytestring containers directory
          filemanip filepath hashable text transformers unordered-containers
          zip
        ];
        executableHaskellDepends = [
          ansi-wl-pprint base bytestring containers exceptions filepath
          optparse-applicative zip
        ];
        description = "A library to dump GHC's STG representation";
        license = lib.licenses.bsd3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  variant = if doBenchmark then pkgs.haskell.lib.doBenchmark else pkgs.lib.id;

  drv = variant (haskellPackages.callPackage f {});

in

  if pkgs.lib.inNixShell then drv.env else drv
