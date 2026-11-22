# The icon sets, pinned to the versions shadcn/ui's apps/v4 uses
# (package.json, pnpm-lock.yaml): lucide-react and @tabler/icons-react.
# `nix run .#gen-icons` (from loon's root) runs tools/gen-icons.mjs on them.
{ pkgs }:
let
  lucide-react = pkgs.fetchzip {
    url = "https://registry.npmjs.org/lucide-react/-/lucide-react-0.474.0.tgz";
    hash = "sha256-6528nOODa8cdLClBKbjjeIcLAjAFQ7jg5e/eCbKzZcE=";
  };
  tabler-icons-react = pkgs.fetchzip {
    url = "https://registry.npmjs.org/@tabler/icons-react/-/icons-react-3.34.1.tgz";
    hash = "sha256-H0ifZsxABIqyJecmZYANUah1rNKMSjh5868TF7QzxKA=";
  };
in
pkgs.writeShellApplication {
  name = "gen-icons";
  runtimeInputs = [ pkgs.nodejs ];
  text = ''
    if [ ! -f tools/gen-icons.mjs ]; then
      echo "gen-icons: run it from loon's root" >&2
      exit 1
    fi
    LUCIDE_REACT=${lucide-react} TABLER_ICONS_REACT=${tabler-icons-react} \
      node tools/gen-icons.mjs
  '';
}
