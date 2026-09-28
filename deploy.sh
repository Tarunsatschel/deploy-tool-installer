#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Deploy.
#
#   curl -fsSL https://raw.githubusercontent.com/Tarunsatschel/deploy-tool-installer/main/deploy.sh \
#     | bash -s -- --org liquidity-alt --repo exchange2.0 --branch beta
#
# The `-s --` before your flags is what passes them to the tool rather than to
# bash. Without --yes it is a dry run and changes nothing.
#
# Your workspace (chart clones, application clones, logs) persists between runs.
# The tool itself is fetched for this run and deleted when it finishes.
# ---------------------------------------------------------------------------
set -uo pipefail

WORKSPACE="${WORKSPACE:-$HOME/.deploy-workspace}"
REPO_SLUG="${REPO_SLUG:-Tarunsatschel/deploy-tool}"
REPO_REF="${REPO_REF:-main}"

RED=$'[1;31m'; GRN=$'[1;32m'; BLU=$'[1;34m'; DIM=$'[2m'; OFF=$'[0m'
die() { printf "
${RED}%s${OFF}

" "$*" >&2; exit 1; }

# Fetch the tool into a temp dir and delete it when this command exits, so no
# copy of it is left behind. The workspace - the expensive part, meaning the
# chart clones, application clones and run logs - lives in WORKSPACE and stays.
fetch_tool() {
  command -v git >/dev/null 2>&1 || die "git is not installed.
  macOS:  brew install git"
  command -v gh  >/dev/null 2>&1 || die "The GitHub CLI is not installed. It is how this reaches the tool.
  macOS:  brew install gh
  Linux:  https://github.com/cli/cli#installation

Then run:  gh auth login      (choose HTTPS, grant 'repo' and 'read:packages')
and run this command again."
  gh auth status >/dev/null 2>&1 || die "You are not logged in to GitHub.

Run:  gh auth login      (choose HTTPS, grant 'repo' and 'read:packages')
then run this command again."

  TOOL_TMP="$(mktemp -d "${TMPDIR:-/tmp}/deploy-tool.XXXXXX")" || die "could not create a temp dir"
  trap "rm -rf '$TOOL_TMP'" EXIT INT TERM
  printf "${DIM}fetching the tool (temporary, removed when this finishes)...${OFF}
"
  gh api "repos/$REPO_SLUG/tarball/$REPO_REF" > "$TOOL_TMP/t.tgz" 2>/dev/null \
    || die "Could not download $REPO_SLUG.

You are logged in, so this is almost certainly missing access.
Ask Tarun for read access to that repository, then run this command again."
  tar -xzf "$TOOL_TMP/t.tgz" -C "$TOOL_TMP" --strip-components=1 \
    || die "the download was corrupt - run the command again"
  rm -f "$TOOL_TMP/t.tgz"
  chmod +x "$TOOL_TMP/bin/deploy.sh" "$TOOL_TMP/setup.sh" 2>/dev/null
  [ -x "$TOOL_TMP/bin/deploy.sh" ] || die "the download is missing bin/deploy.sh"

  export CACHE_DIR="$WORKSPACE/cache"
  export LOG_DIR="$WORKSPACE/logs"
  mkdir -p "$CACHE_DIR/devops-files" "$CACHE_DIR/apps/liquidity-alt" \
           "$CACHE_DIR/apps/satschel" "$LOG_DIR"
}

[ "$#" -gt 0 ] || die "No flags given. For example:

  curl -fsSL .../deploy.sh | bash -s -- --org liquidity-alt --repo exchange2.0 --branch beta

Leave off --yes for a dry run.
Run the setup command first if you want a report of what you can reach."

fetch_tool
# </dev/null matters: this script arrives on stdin, so without it the tool would
# inherit the remains of the curl pipe instead of a clean descriptor.
# Not exec: exec replaces this shell, so the EXIT trap would never run and the
# temp copy of the tool would be left behind. Call it, keep the status, exit.
# </dev/null matters too: this script arrives on stdin, so without it the tool
# inherits the remains of the curl pipe instead of a clean descriptor.
"$TOOL_TMP/bin/deploy.sh" "$@" </dev/null
exit $?
