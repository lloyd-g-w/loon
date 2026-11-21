#!/usr/bin/env bash
# Runs the e2e scripts against the built docs site, in each browser, and
# diffs what they print with ENGINE.expected (chromium.expected,
# firefox.expected, webkit.expected): pages.mjs (every page, navigation,
# back/forward, the outline), theme.mjs (light/dark, accents, persistence),
# examples.mjs (View Code, copying, highlighting, Copy Page, overlays from previews), search.mjs, and
# mobile.mjs on a phone and a small phone. Pages are found from the
# sidebar, so new components are checked without changes here.
#
# Needs node, PLAYWRIGHT_MODULE (the playwright package's index.mjs) and
# PLAYWRIGHT_BROWSERS_PATH (and, for WebKit on Linux without a system GL
# driver, __EGL_VENDOR_LIBRARY_DIRS pointing at Mesa's egl_vendor.d), plus:
#   LOON_DOCS       the built site (default: _build/default/docs/bin/site)
#   ENGINES         browsers to run (default: chromium firefox webkit)
#   SHOTS           a directory to save screenshots of each step in
#   JOBS            how many scripts run at once (default: the number of CPUs)
#   SCRIPT_TIMEOUT  seconds a script may take (default 600: a full run loads every page in three engines at once)
#   UPDATE=1        rewrite ENGINE.expected instead of diffing
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOON_DOCS="${LOON_DOCS:-$here/../_build/default/docs/bin/site}"
test -f "$LOON_DOCS/main.bc.js" || { echo "no site at $LOON_DOCS: build it (dune build)" >&2; exit 1; }
if [ -n "${SHOTS:-}" ]; then mkdir -p "$SHOTS"; export SHOTS="$(cd "$SHOTS" && pwd)"; fi
tmp="$(mktemp -d)"
trap 'status=$?; rm -rf "$tmp"; exit $status' EXIT

scripts="pages theme examples search mobile:phone mobile:small"
engines="${ENGINES:-chromium firefox webkit}"
jobs="${JOBS:-$(nproc 2>/dev/null || echo 4)}"

run_one() {
	# script:part runs script.mjs ENGINE part
	local engine=$1 script=$2 status=0
	local file=${script%%:*} part=${script#*:}
	[ "$part" != "$script" ] || part=""
	timeout -k 10 "${SCRIPT_TIMEOUT:-600}" node "$here/$file.mjs" "$engine" $part \
		>"$tmp/$engine-$script.out" 2>"$tmp/$engine-$script.err" || status=$?
	echo "$status" >"$tmp/$engine-$script.status"
}
for engine in $engines; do
	for script in $scripts; do
		while [ "$(jobs -rp | wc -l)" -ge "$jobs" ]; do wait -n || true; done
		run_one "$engine" "$script" &
	done
done
wait

failed=""
for engine in $engines; do
	: >"$tmp/$engine.actual"
	ok=1
	for script in $scripts; do
		{ echo "== $script"; cat "$tmp/$engine-$script.out"; } >>"$tmp/$engine.actual"
		if [ "$(cat "$tmp/$engine-$script.status")" != 0 ]; then
			failed="$failed $engine/$script"
			ok=""
			echo "--- $engine $script failed (status $(cat "$tmp/$engine-$script.status")); its output and stderr:" >&2
			tail -20 "$tmp/$engine-$script.out" >&2
			cat "$tmp/$engine-$script.err" >&2
		fi
	done
	if [ "${UPDATE:-}" = 1 ] && [ -n "$ok" ]; then
		cp "$tmp/$engine.actual" "$here/$engine.expected"
		echo "updated $here/$engine.expected"
	else
		touch "$here/$engine.expected"
		diff -u "$here/$engine.expected" "$tmp/$engine.actual" || failed="$failed $engine/diff"
	fi
done
if [ -n "$failed" ]; then
	echo "failed:$failed" >&2
	exit 1
fi
echo "e2e ok: $engines"
