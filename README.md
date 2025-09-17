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
