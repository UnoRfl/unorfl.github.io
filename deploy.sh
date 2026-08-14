#!/usr/bin/env bash
# Deploy this portfolio to https://unorfl.github.io/
#
#   bash deploy.sh
#
# If the GitHub CLI (gh) is installed and logged in, this does everything:
# creates the repo, pushes, and switches Pages on. Otherwise it does the git
# half and tells you the one switch to flip by hand.

set -euo pipefail

USER_NAME="UnoRfl"
REPO="unorfl.github.io"
REMOTE="https://github.com/${USER_NAME}/${REPO}.git"

cd "$(dirname "$0")"

if [ ! -f index.html ]; then
  echo "✗ index.html not found. Run this from the folder you unzipped."
  exit 1
fi

echo "→ preparing repository"
[ -d .git ] || git init -q
git add index.html README.md deploy.sh 2>/dev/null || git add index.html README.md
git diff --cached --quiet || git commit -qm "portfolio: Juan Rafael / codename Uno"
git branch -M main

if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  echo "→ gh detected — creating repo and pushing"

  if gh repo view "${USER_NAME}/${REPO}" >/dev/null 2>&1; then
    echo "  repo already exists, reusing it"
    git remote remove origin 2>/dev/null || true
    git remote add origin "$REMOTE"
    git push -u origin main --force-with-lease
  else
    gh repo create "$REPO" --public --source=. --remote=origin --push
  fi

  echo "→ enabling GitHub Pages (main / root)"
  gh api -X POST "repos/${USER_NAME}/${REPO}/pages" \
      -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 \
    || gh api -X PUT "repos/${USER_NAME}/${REPO}/pages" \
      -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 \
    || echo "  (Pages may already be on — check the settings link below)"

  echo
  echo "✓ done. Live in ~1-2 minutes at:  https://${USER_NAME,,}.github.io/"
  echo "  settings: https://github.com/${USER_NAME}/${REPO}/settings/pages"
else
  echo "→ gh not found (or not logged in) — doing the git half"
  echo
  echo "  First create an EMPTY public repo named exactly:  ${REPO}"
  echo "  at https://github.com/new  (no README, no .gitignore, no license)"
  echo
  read -r -p "  Press Enter once that repo exists... " _

  git remote remove origin 2>/dev/null || true
  git remote add origin "$REMOTE"
  git push -u origin main

  echo
  echo "✓ pushed. One switch left:"
  echo "  https://github.com/${USER_NAME}/${REPO}/settings/pages"
  echo "  Source: 'Deploy from a branch' → Branch: main → Folder: / (root) → Save"
  echo
  echo "  Then it's live at:  https://${USER_NAME,,}.github.io/"
fi
