{
  description = "A Bonsai_web app using loon (shadcn/ui for OxCaml)";

  # loon's OxCaml packages come from prigh's binary cache.
  nixConfig = {
    extra-substituters = [ "https://attic.caduc.co/prigh" ];
    extra-trusted-public-keys = [
      "prigh:n6wPXDyh+4CS5uoNgXQ3QvKjOSLE7ED87qIiTSvih1A="
    ];
  };

  inputs = {
    loon.url = "github:lloyd-g-w/loon";
    nixpkgs.follows = "loon/nixpkgs";
  };

  outputs =
    { nixpkgs, loon, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs (builtins.attrNames loon.packages);
      # loon (the library, with OxCaml, dune, js_of_ocaml and Bonsai) and
      # Tailwind v4, which builds main.css.
      deps = system: [
        loon.packages.${system}.loon
        nixpkgs.legacyPackages.${system}.tailwindcss_4
      ];
    in
    {
      packages = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.stdenv.mkDerivation {
          name = "app";
          src = ./.;
          nativeBuildInputs = deps system;
          buildPhase = "dune build --profile release ./main.bc.js ./main.css";
          installPhase = ''
            mkdir -p "$out"
            cp index.html _build/default/main.bc.js _build/default/main.css "$out"
          '';
        };
      });

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell { packages = deps system; };
      });
    };
}
