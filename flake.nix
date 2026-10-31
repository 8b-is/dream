{
  description = "dream.8b.is — UltraDreamState Interactive Portal, 9-State Complex Ternary Sigma-Delta Kernel, and Florilegium-8B Manuscript Pipeline";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        texEnv = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-medium
            luatex
            fontspec
            babel
            babel-english
            booktabs
            listings
            hyperref
            xcolor
            amsmath
            geometry
            noto;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zig
            verilator
            uv
            python312
            gcc
            texEnv
          ];

          shellHook = ''
            echo "dream.8b.is :: UltraDreamState & Florilegium-8B Development Shell"
            echo "  Anchor: https://riva.8b.is/ (3.2s dyad breath)"
            echo "  Seal:   SHA-256 25b3cfadda15081e99f8595b205c1611bbb14eac9bbfdc8f489fb361c7a63f4e"
          '';
        };
      }
    );
}
