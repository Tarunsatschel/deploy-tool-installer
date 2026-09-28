# deploy-tool-installer

One-line bootstrap for the deploy tool.

```bash
curl -fsSL https://raw.githubusercontent.com/Tarunsatschel/deploy-tool-installer/main/setup.sh | bash
```

Prerequisites: `gh` installed and `gh auth login` done. Nothing else.

It downloads the tool into `~/.deploy-tool`, runs its setup, and leaves you with a `deploy.sh`
command. Safe to re-run: it updates the tool and re-checks everything.

This repository is public **only** so the URL above needs no authentication. It holds this bootstrap
and nothing else: no infrastructure detail, no project identifiers, no credentials. The tool itself
stays private and is fetched with your own GitHub login.

## Deploying straight from a raw URL

If you would rather not rely on `deploy.sh` being on your PATH, there is a raw URL for that too. It
installs the tool on first use, then passes your flags straight through:

```bash
curl -fsSL https://raw.githubusercontent.com/Tarunsatschel/deploy-tool-installer/main/deploy.sh \
  | bash -s -- --org liquidity-alt --repo exchange2.0 --branch beta
```

The `-s --` before your flags is what sends them to the tool instead of to bash. Without `--yes` it
is a dry run and changes nothing. Add `--yes` once the printed plan looks right.

After running the setup once, `deploy.sh --org ... --branch ...` on your PATH does exactly the same
thing and is shorter to type.
