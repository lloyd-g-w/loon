{
  description = "loon: a component library for Bonsai_web on OxCaml";

  # The OxCaml toolchain is the one prigh pins (same inputs, same pins), so
  # prigh's binary cache already has every package loon depends on.
  nixConfig = {
    extra-substituters = [ "https://attic.caduc.co/prigh" ];
    extra-trusted-public-keys = [
      "prigh:n6wPXDyh+4CS5uoNgXQ3QvKjOSLE7ED87qIiTSvih1A="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    opam-nix.url = "github:tweag/opam-nix";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    ox-opam-repository = {
      url = "github:oxcaml/opam-repository";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      opam-nix,
      opam-repository,
      ox-opam-repository,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        on = opam-nix.lib.${system};

        # nix/opam-repository first so its packages shadow the others, then
        # OxCaml's, whose `+ox` packages shadow upstream's.
        repos = [
          ./nix/opam-repository
          ox-opam-repository
          opam-repository
        ];

        # Exact versions keep opam-nix's solver inside its IFD timeout and
        # force the OxCaml compiler (nix/README.md).
        query =
          let
            pins = import ./nix/ox-pins.nix;
          in
          if pkgs.stdenv.hostPlatform.isLinux then
            pins
          else
            builtins.removeAttrs pins [
              "eio_linux"
              "uring"
            ];

        overlay = final: prev: {
          oxcaml-compiler = prev.oxcaml-compiler.overrideAttrs (oa: {
            patches = (oa.patches or [ ]) ++ [
              ./nix/fix-floatarithmem.patch
              ./nix/limit-dune-jobs.patch
            ];
            nativeBuildInputs =
              (oa.nativeBuildInputs or [ ])
              ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.darwin.cctools ];
            env =
              (oa.env or { })
              // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin { JOBS = "2"; };
          });
        };

        src = lib.cleanSourceWith {
          src = ./.;
          filter =
            path: type:
            let
              base = baseNameOf path;
            in
            !(lib.elem base [
              "_build"
              "result"
              "e2e"
              ".github"
            ]);
        };

        scope =
          (on.buildOpamProject' {
            inherit repos;
            resolveArgs = {
              depopts = false;
              dev = false;
            };
          } src query).overrideScope
            overlay;

        # Tailwind v4 compiles the components' class strings into loon.css (as
        # shadcn/ui is styled), in the build and the dev shell.
        tailwind = pkgs.tailwindcss_4;

        loon = scope.loon.overrideAttrs (oa: {
          nativeBuildInputs = (oa.nativeBuildInputs or [ ]) ++ [ tailwind ];
          meta = (oa.meta or { }) // {
            mainProgram = "loon";
          };
        });

        # The documentation site: loon's gallery, built whole-program.
        docsRoot = "${loon}/share/loon/docs";

        playwright = [
          pkgs.nodejs
          pkgs.playwright-test
          pkgs.playwright-driver.browsers
          pkgs.dejavu_fonts
        ];
      in
      {
        legacyPackages = scope;

        packages = {
          default = loon;
          inherit loon;
          docs = pkgs.runCommand "loon-docs" { } ''cp -r ${docsRoot} "$out"'';
        };

        apps.default = {
          type = "app";
          program = "${loon}/bin/loon";
        };

        # Regenerates src/icon.ml and src/tabler.ml (tools/icons.nix).
        apps.gen-icons = {
          type = "app";
          program = lib.getExe (import ./tools/icons.nix { inherit pkgs; });
        };

        # e2e/: the documentation site in Chromium, Firefox and WebKit.
        checks.e2e =
          if pkgs.stdenv.hostPlatform.isLinux then
            pkgs.runCommand "loon-e2e" { nativeBuildInputs = playwright; } ''
              cat > fonts.conf <<EOF
              <?xml version="1.0"?>
              <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
              <fontconfig>
                <dir>${pkgs.dejavu_fonts}/share/fonts</dir>
                <cachedir>$PWD/font-cache</cachedir>
              </fontconfig>
              EOF
              export FONTCONFIG_FILE="$PWD/fonts.conf"
              export PLAYWRIGHT_BROWSERS_PATH=${pkgs.playwright-driver.browsers}
              export PLAYWRIGHT_MODULE=${pkgs.playwright-test}/lib/node_modules/playwright/index.mjs
              export __EGL_VENDOR_LIBRARY_DIRS=${pkgs.mesa}/share/glvnd/egl_vendor.d
              export LOON_DOCS=${docsRoot}
              export HOME="$PWD/home"
              mkdir -p "$HOME"
              cp -r ${./e2e} e2e
              chmod -R u+w e2e
              ${pkgs.runtimeShell} e2e/run.sh
              mkdir "$out"
            ''
          else
            pkgs.runCommand "loon-e2e-skipped" { } ''touch "$out"'';

        devShells.default = pkgs.mkShell {
          inputsFrom = [ loon ];
          buildInputs = [
            scope.bonsai_web_test
            scope.expect_test_helpers_core
            # upstream ocamlformat: the OxCaml one does not evaluate (see
            # prigh); format OxCaml syntax by hand.
            pkgs.ocamlformat
            pkgs.ripgrep
            pkgs.nodejs
            tailwind
          ];
          shellHook = ''
            PATH=$(printf '%s' "$PATH" | tr : '\n' | awk '!/-opam\/bin$/ || !seen++' | paste -sd : -)
          '';
        };
      }
    );
}
