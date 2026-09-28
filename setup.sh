#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Bootstrap for the deploy tool.
#
#   curl -fsSL https://raw.githubusercontent.com/Tarunsatschel/deploy-tool-installer/main/setup.sh | bash
#
# This file is deliberately tiny and contains no infrastructure detail. All it
# does is make sure the GitHub CLI is usable, fetch the tool itself, and hand
# over to the real setup inside it.
#
# Re-run it any time: it updates the tool and re-checks everything.
# ---------------------------------------------------------------------------
set -uo pipefail

REPO_SLUG="${REPO_SLUG:-Tarunsatschel/deploy-tool}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.deploy-tool}"

RED=$'\033[1;31m'; GRN=$'\033[1;32m'; BLU=$'\033[1;34m'; DIM=$'\033[2m'; OFF=$'\033[0m'
die() { printf "\n${RED}%s${OFF}\n\n" "$*" >&2; exit 1; }

printf "${BLU}==> Fetching the deploy tool${OFF}\n"

command -v git >/dev/null 2>&1 || die "git is not installed.
  macOS:  brew install git"

if ! command -v gh >/dev/null 2>&1; then
  die "The GitHub CLI is not installed. The tool lives in a private repo, so it is required.
  macOS:  brew install gh
  Linux:  https://github.com/cli/cli#installation

Then run:  gh auth login      (choose HTTPS, grant 'repo' and 'read:packages')
and re-run this command."
fi

if ! gh auth status >/dev/null 2>&1; then
  die "You are not logged in to GitHub.

Run:  gh auth login      (choose HTTPS, grant 'repo' and 'read:packages')
then re-run this command."
fi

if [ -d "$INSTALL_DIR/.git" ]; then
  git -C "$INSTALL_DIR" pull --quiet --ff-only 2>/dev/null \
    && printf "  ${GRN}OK${OFF}    updated %s\n" "$INSTALL_DIR" \
    || printf "  ${DIM}could not fast-forward %s, using it as it is${OFF}\n" "$INSTALL_DIR"
else
  gh repo clone "$REPO_SLUG" "$INSTALL_DIR" -- -q 2>/dev/null \
    || die "Could not download $REPO_SLUG.

You are logged in, so this is almost certainly missing access.
Ask Tarun for read access to that repository, then re-run this command."
  printf "  ${GRN}OK${OFF}    installed into %s\n" "$INSTALL_DIR"
fi

[ -x "$INSTALL_DIR/setup.sh" ] || die "$INSTALL_DIR/setup.sh is missing or not executable."

# Hand over to the real setup inside the tool, which does all the environment checks.
exec "$INSTALL_DIR/setup.sh"
