#!/usr/bin/env bash
set -euo pipefail

# scaffold_github_repo.sh
# Creates README.md, .gitignore, LICENSE, CONTRIBUTING.md, run_examples.sh,
# removes githubprep.sh if present, makes scanner scripts executable,
# initializes git, commits, and optionally adds/pushes a remote.
#
# Usage:
#   Place this file in your npm_scanner directory where check_shai_hulud.sh
#   and scan_shai_hulud_multi.sh live. Then run:
#     chmod +x scaffold_github_repo.sh
#     ./scaffold_github_repo.sh
#
# The script will prompt before pushing to a remote.

TS=$(date +%Y%m%d_%H%M%S)
PROJECT_DIR="$(pwd)"
REPO_NAME="$(basename "$PROJECT_DIR")"

# Required scanner scripts
REQUIRED_SCRIPTS=("check_shai_hulud.sh" "scan_shai_hulud_multi.sh")

echo "Scaffold starting for project: $REPO_NAME"
echo

# 0. Verify presence of scanner scripts
for s in "${REQUIRED_SCRIPTS[@]}"; do
  if [ ! -f "$s" ]; then
    echo "ERROR: Required script '$s' not found in $PROJECT_DIR"
    echo "Place your scanner scripts here and re-run the scaffold."
    exit 1
  fi
done

# 1. Remove legacy githubprep.sh if present
if [ -f "githubprep.sh" ]; then
  echo "Removing legacy file githubprep.sh"
  rm -f githubprep.sh
fi

# 2. Write .gitignore
cat > .gitignore <<'GITIGNORE'
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Node / npm
node_modules/
npm-debug.log
package-lock.json
yarn.lock

# Logs
*.log

# Environment
.env
.env.local

# IDEs and editors
.vscode/
.idea/
*.sublime-project
*.sublime-workspace

# Local OS files
Thumbs.db
Desktop.ini

# Generated scan logs
shai_hulud_scan_*.log
GITIGNORE

echo ".gitignore created."

# 3. Write LICENSE (MIT)
cat > LICENSE <<'LICENSE'
MIT License

Copyright (c) '"$(date +%Y)"

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files the "Software", to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
LICENSE

echo "LICENSE created."

# 4. Write CONTRIBUTING.md
cat > CONTRIBUTING.md <<'CONTRIB'
Contributing

Thanks for your interest in improving detection. Keep contributions focused on:
- New detection checks and checks that are safe to run on user machines.
- Improvements to logging and reporting formats.
- Tests or examples demonstrating detection improvements.

Do not add code that fetches or executes suspicious remote payloads. If a pull request adds a new check that may have side effects, document it clearly and make the default behavior non-destructive.
CONTRIB

echo "CONTRIBUTING.md created."

# 5. Write README.md with detailed guidance
cat > README.md <<'README'
# npm_scanner - Shai-Hulud NPM Worm Scanner

Status: Detection tooling for defensive use only. Use with caution.

## Summary

This repo contains Bash scanners designed to help detect signs of compromise from the Shai-Hulud npm worm (September 2025). The worm abused npm postinstall hooks to execute malicious JavaScript during `npm install`, steal credentials, exfiltrate them to public GitHub repositories named "Shai-Hulud", and self-propagate by republishing packages when it had publish access.

These scripts are a practical first pass for macOS development machines. They are not a replacement for professional incident response.

## Files

- `check_shai_hulud.sh` - lightweight single-project scanner meant to be run inside a project folder.
- `scan_shai_hulud_multi.sh` - multi-project scanner that walks directories you pass in, logs actions, and offers safe interactive removal for detected packages or artifacts.
- `.gitignore` - excludes node_modules, logs, macOS junk and generated scan logs.
- `CONTRIBUTING.md` - contribution rules and safety guidance.
- `LICENSE` - MIT license.
- `run_examples.sh` - small helper showing example runs.

## Quick usage

Make the scanner scripts executable:

```bash
chmod +x check_shai_hulud.sh scan_shai_hulud_multi.sh
