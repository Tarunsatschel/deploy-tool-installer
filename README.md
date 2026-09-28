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
