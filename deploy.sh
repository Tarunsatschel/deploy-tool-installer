#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Deploy, from a raw URL, with no local checkout and nothing on your PATH.
#
#   curl -fsSL https://raw.githubusercontent.com/Tarunsatschel/deploy-tool-installer/main/deploy.sh \
#     | bash -s -- --org liquidity-alt --repo exchange2.0 --branch beta
#
# Note the `-s --` before your flags: that is what passes them through to the
# tool rather than to bash itself. Without --yes it is a dry run and changes
# nothing.
#
# This file is deliberately tiny and holds no infrastructure detail. It makes
# sure the tool is present, then hands your flags to it unchanged.
#
# If you have run the setup once, `deploy.sh <flags>` on your PATH does the same
# thing and is quicker to type.
# ---------------------------------------------------------------------------
set -uo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.deploy-tool}"
BOOTSTRAP_URL="${BOOTSTRAP_URL:-https://raw.githubusercontent.com/Tarunsatschel/deploy-tool-installer/main/setup.sh}"

RED=$'\033[1;31m'; DIM=$'\033[2m'; OFF=$'\033[0m'
die() { printf "\n${RED}%s${OFF}\n\n" "$*" >&2; exit 1; }

if [ ! -x "$INSTALL_DIR/bin/deploy.sh" ]; then
  printf "${DIM}First run: installing the tool into %s ...${OFF}\n" "$INSTALL_DIR"
  curl -fsSL "$BOOTSTRAP_URL" | bash \
    || die "Setup did not finish. Fix what it reported above, then run this again."
  [ -x "$INSTALL_DIR/bin/deploy.sh" ] \
    || die "Setup ran but $INSTALL_DIR/bin/deploy.sh is still missing."
fi

[ "$#" -gt 0 ] || die "No flags given. For example:

  curl -fsSL .../deploy.sh | bash -s -- --org liquidity-alt --repo exchange2.0 --branch beta

Leave off --yes for a dry run. Full usage: $INSTALL_DIR/docs/usage.md"

# </dev/null matters: this script arrives on stdin, so the tool would otherwise
# inherit the remains of the pipe instead of a real terminal.
exec "$INSTALL_DIR/bin/deploy.sh" "$@" </dev/null
