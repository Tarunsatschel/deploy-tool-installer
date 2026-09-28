#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# One-command setup.
#
#   curl -fsSL https://raw.githubusercontent.com/Tarunsatschel/deploy-tool-installer/main/setup.sh | bash
#
# Prepares your machine: checks the tools and logins you need, tells you which
# clusters you can reach, creates the workspace, and clones the chart repos.
#
# The workspace it builds stays on your machine. The tool that does the work does
# NOT: it is fetched to a temporary directory for the run and deleted afterwards,
# so there is no copy of it to go stale or maintain.
#
# Changes nothing in GCP and deploys nothing. Safe to re-run any time.
# ---------------------------------------------------------------------------
set -uo pipefail

# DEPLOY_WORKSPACE is the documented override and wins; WORKSPACE is kept as an
# alias. Whatever wins is exported as DEPLOY_WORKSPACE and nothing else, so
# bin/lib/common.sh stays the single place that decides the real paths. An earlier
# version pre-exported CACHE_DIR/LOG_DIR here, which silently beat DEPLOY_WORKSPACE
# inside the tool while the output still claimed to honour it.
WORKSPACE="${DEPLOY_WORKSPACE:-${WORKSPACE:-$HOME/.deploy-workspace}}"
REPO_SLUG="${REPO_SLUG:-Tarunsatschel/deploy-tool}"
REPO_REF="${REPO_REF:-main}"

if [ -t 1 ]; then
  RED=$'[1;31m'; GRN=$'[1;32m'; BLU=$'[1;34m'; DIM=$'[2m'; OFF=$'[0m'
else
  RED=''; GRN=''; BLU=''; DIM=''; OFF=''
fi
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

  export DEPLOY_WORKSPACE="$WORKSPACE"
  mkdir -p "$WORKSPACE/cache/devops-files" "$WORKSPACE/cache/apps/liquidity-alt" \
           "$WORKSPACE/cache/apps/satschel" "$WORKSPACE/logs"
}

fetch_tool
printf "${BLU}==> workspace: %s${OFF}\n" "$WORKSPACE"
# Not exec: exec replaces this shell, so the EXIT trap would never run and the
# temp copy of the tool would be left behind. Call it, keep the status, exit.
EPHEMERAL=1 "$TOOL_TMP/setup.sh"
exit $?
