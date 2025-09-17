#!/bin/bash
set -euo pipefail

echo "🔍 Checking for Shai-Hulud npm worm compromise..."

# 1. Check Node.js and npm versions
echo "📦 Node.js version: $(node -v 2>/dev/null || echo 'Not installed')"
echo "📦 npm version: $(npm -v 2>/dev/null || echo 'Not installed')"

# 2. Run npm audit in current project
if [ -f package.json ]; then
  echo "📁 Running npm audit in current project..."
  npm audit || echo "⚠️ npm audit failed or found issues"
else
  echo "📁 No package.json found in current directory — skipping local audit"
fi

# 3. List global packages
echo "🌐 Listing globally installed npm packages..."
npm list -g --depth=0 || echo "⚠️ Failed to list global packages"

# 4. Check for known compromised packages
echo "🧬 Checking for known compromised packages..."
npm ls | grep -E '@ctrl/tinycolor|ngx-toastr|angulartics2|rxnt-authentication' || echo "✅ No known compromised packages found locally"
npm ls -g | grep -E '@ctrl/tinycolor|ngx-toastr|angulartics2|rxnt-authentication' || echo "✅ No known compromised packages found globally"

# 5. Search for suspicious postinstall scripts
echo "🕵️ Scanning node_modules for malicious postinstall scripts..."
find node_modules -name package.json -exec grep -H '"postinstall"' {} \; | grep -E 'http|curl|wget' || echo "✅ No suspicious postinstall scripts found"

# 6. Look for bundle.js artifacts
echo "🧨 Searching for bundle.js files..."
find node_modules -name "bundle.js" -exec grep -H "Shai-Hulud" {} \; || echo "✅ No bundle.js artifacts found in node_modules"
mdfind "bundle.js" || echo "✅ No bundle.js found via Spotlight"

# 7. Check /tmp for processor.sh
echo "🧼 Checking /tmp for worm artifacts..."
ls -la /tmp | grep processor.sh && echo "⚠️ Found suspicious /tmp/processor.sh" || echo "✅ No processor.sh found in /tmp"

# 8. Check for unexpected GitHub repos
echo "🌐 Checking for suspicious GitHub repos (manual step)"
echo "👉 Visit https://github.com and search your account for repos named 'Shai-Hulud'"

# 9. Scan system logs for suspicious activity
echo "📜 Scanning system logs for npm/GitHub/token activity in last 24h..."
log show --predicate 'subsystem == "com.apple.launchd" OR process == "node"' --last 1d | grep -i "npm\|github\|token" || echo "✅ No suspicious log entries found"

# 10. Check for unexpected network activity
echo "🌐 Checking for active network connections to GitHub..."
sudo netstat -an | grep ESTABLISHED | grep github || echo "✅ No active GitHub connections detected"

# 11. Check for unexpected npm/node processes
echo "🧠 Checking running processes for npm/node..."
ps aux | grep -E 'npm|node' | grep -v grep || echo "✅ No suspicious npm/node processes running"

echo "✅ Scan complete. If any ⚠️ warnings appeared, investigate further or rotate credentials."
