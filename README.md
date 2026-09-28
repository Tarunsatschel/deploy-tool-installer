# deploy-tool-installer

Two commands. Nothing to clone, and no copy of the tool left on your machine.

**Prerequisites:** `gh` installed and `gh auth login` done. Nothing else.

## 1. Set up (run once)

```bash
curl -fsSL https://raw.githubusercontent.com/Tarunsatschel/deploy-tool-installer/main/setup.sh | bash
```

Checks your tools and logins, reports which clusters you can reach and what access to request,
creates the workspace at `~/.deploy-workspace`, and clones the chart repos.

Changes nothing in GCP and deploys nothing. Safe to re-run.

## 2. Deploy

```bash
curl -fsSL https://raw.githubusercontent.com/Tarunsatschel/deploy-tool-installer/main/deploy.sh \
  | bash -s -- --org liquidity-alt --repo exchange2.0 --branch beta
```

The `-s --` before your flags is what passes them to the tool instead of to bash. Without `--yes`
it is a dry run: it prints the plan and changes nothing. Add `--yes` when the plan looks right.

| What you want | Flags |
|---|---|
| Deploy a branch to dev or beta | `--org <org> --repo <repo> --branch <branch> --yes` |
| Deploy a release to production | `--org <org> --repo <repo> --target <branch> --release-tag <tag> --yes` |
| A repo that builds several services | add `--service <name>` or `--service all` |
| Redeploy an existing image, no rebuild | add `--image-tag <tag>` |
| Build in GCP instead of locally | add `--cloud-build` |

## What lives where

| | Where | Persists? |
|---|---|---|
| Chart and pipeline-config clones | `~/.deploy-workspace/cache/devops-files/<org>/` | yes |
| Application clones | `~/.deploy-workspace/cache/apps/<org>/<repo>/` | yes |
| Run logs | `~/.deploy-workspace/logs/` | yes |
| **The tool itself** | a temp directory, for the duration of the command | **no** |

The dependencies stay because they are slow to fetch. The tool does not, so there is no stale copy
to maintain and every run uses the current version.

## Why this repo is public

Only so the two URLs above need no authentication. It holds these two wrappers and nothing else: no
infrastructure detail, no project identifiers, no credentials. The tool is private and is fetched
with your own GitHub login, so there is no shared token anywhere.
