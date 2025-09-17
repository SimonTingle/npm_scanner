#!/bin/bash
set -euo pipefail

TS=$(date +%Y%m%d_%H%M%S)
LOG="shai_hulud_scan_${TS}.log"
touch "$LOG"

echo "🛡️ Shai-Hulud NPM Worm Scanner — $(date)" | tee -a "$LOG"
echo "Scanning directories: $*" | tee -a "$LOG"

# List of known compromised packages (partial)
KNOWN_PKGS="@ctrl/tinycolor ngx-toastr angulartics2 rxnt-authentication"

scan_project() {
  local dir="$1"
  echo -e "\n📁 Scanning project: $dir" | tee -a "$LOG"
  if [ ! -f "$dir/package.json" ]; then
    echo "❌ No package.json found — skipping" | tee -a "$LOG"
    return
  fi

  cd "$dir"

  echo "🔍 Running npm audit..." | tee -a "$LOG"
  npm audit >> "$LOG" 2>&1 || echo "⚠️ npm audit failed or found issues" | tee -a "$LOG"

  echo "📦 Checking for known compromised packages..." | tee -a "$LOG"
  for pkg in $KNOWN_PKGS; do
    if npm ls "$pkg" >/dev/null 2>&1; then
      echo "⚠️ Found suspicious package: $pkg" | tee -a "$LOG"
      echo "Do you want to remove $pkg from $dir? [y/N]"
      read -r confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        npm uninstall "$pkg" >> "$LOG" 2>&1 && echo "✅ Removed $pkg" | tee -a "$LOG"
      else
        echo "⏭️ Skipped removal of $pkg" | tee -a "$LOG"
      fi
    fi
  done

  echo "🕵️ Checking for malicious postinstall scripts..." | tee -a "$LOG"
  find node_modules -name package.json -exec grep -H '"postinstall"' {} \; | grep -E 'http|curl|wget' >> "$LOG" || echo "✅ No suspicious postinstall scripts found" | tee -a "$LOG"

  echo "🧨 Searching for bundle.js files..." | tee -a "$LOG"
  find node_modules -name "bundle.js" -exec grep -H "Shai-Hulud" {} \; >> "$LOG" || echo "✅ No bundle.js artifacts found" | tee -a "$LOG"

  echo "🧼 Checking /tmp for worm artifacts..." | tee -a "$LOG"
  if ls -la /tmp | grep processor.sh; then
    echo "⚠️ Found /tmp/processor.sh — delete it? [y/N]"
    read -r confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      rm /tmp/processor.sh && echo "✅ Deleted /tmp/processor.sh" | tee -a "$LOG"
    else
      echo "⏭️ Skipped deletion" | tee -a "$LOG"
    fi
  else
    echo "✅ No processor.sh found in /tmp" | tee -a "$LOG"
  fi

  cd - >/dev/null
}

for dir in "$@"; do
  scan_project "$dir"
done

echo -e "\n📜 Scan complete. Results saved to $LOG"
echo "🔗 Next: Check your GitHub account for suspicious repos named 'Shai-Hulud'. Rotate any exposed tokens."

