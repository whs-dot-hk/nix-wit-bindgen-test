{
  inputs.crane.url = "github:ipetkov/crane";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  outputs = {
    crane,
    flake-utils,
    nixpkgs,
    rust-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [(import rust-overlay)];
      pkgs = import nixpkgs {
        inherit
          system
          overlays
          ;
      };
      rustToolchain = pkgs.rust-bin.beta.latest.default.override {
        targets = ["wasm32-wasi"];
      };
      craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;
      test = craneLib.buildPackage {
        src = pkgs.lib.cleanSourceWith {
          src = craneLib.path ./.;
          filter = path: type:
            (craneLib.filterCargoSources path type)
            || builtins.match ".*wit$" path != null;
        };
        cargoExtraArgs = "--target wasm32-wasi";
        doCheck = false;
      };
    in {
      packages.default = test;
    });
}
