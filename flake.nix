{
  description = "Conway's Game of Life in Nim";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Nim toolchain
            nim-2_0
            nimlsp
            nimble
            nimlangserver

            # Raylib dependencies
            libGL
            libx11
            libx11.dev
            libxcursor
            libxrandr
            libxinerama
            libxi
            alsa-lib
          ];

          shellHook = ''
            echo "Nim $(nim -version)"
          '';
        };
      }
    );
}
