{ compiler ? "ghc8107" }:

let
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages.${compiler}.override {
            overrides = haskellPackagesNew: haskellPackagesOld: rec {

              external-stg             = haskellPackagesNew.callPackage ./external-stg/external-stg.nix {};
              external-stg-interpreter = haskellPackagesNew.callPackage ./external-stg-interpreter.nix {};
              souffle-haskell          = haskellPackagesNew.callPackage ./souffle-haskell.nix {};
            };
          };
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; };
  unstable = import <unstable> { };

in
  rec {
    external-stg             = pkgs.haskell.packages.${compiler}.external-stg;
    external-stg-interpreter = pkgs.haskell.packages.${compiler}.external-stg-interpreter;

    external-stg-interpreter-shell = pkgs.haskell.packages.${compiler}.shellFor {
      packages = p: [external-stg-interpreter];
    };
  }
