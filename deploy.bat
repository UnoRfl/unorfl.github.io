@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ============================================
echo   Deploying portfolio to unorfl.github.io
echo ============================================
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo [X] Git is not installed.
  echo     Get it here: https://git-scm.com/download/win
  echo.
  pause
  exit /b 1
)

if not exist index.html (
  echo [X] index.html not found next to this script.
  pause
  exit /b 1
)

echo [1/3] preparing repository
if not exist .git git init -q
git add index.html README.md deploy.sh deploy.bat >nul 2>nul
git diff --cached --quiet
if errorlevel 1 git commit -q -m "portfolio: Juan Rafael / codename Uno"
git branch -M main

where gh >nul 2>nul
if errorlevel 1 goto MANUAL

REM ---------- GitHub CLI path: fully automatic ----------
gh auth status >nul 2>nul
if errorlevel 1 goto MANUAL

echo [2/3] creating repo and pushing via gh
gh repo view UnoRfl/unorfl.github.io >nul 2>nul
if errorlevel 1 (
  gh repo create unorfl.github.io --public --source=. --remote=origin --push
) else (
  echo       repo already exists, reusing it
  git remote remove origin >nul 2>nul
  git remote add origin https://github.com/UnoRfl/unorfl.github.io.git
  git push -u origin main --force-with-lease
)

echo [3/3] enabling GitHub Pages
gh api -X POST repos/UnoRfl/unorfl.github.io/pages -f "source[branch]=main" -f "source[path]=/" >nul 2>nul
if errorlevel 1 gh api -X PUT repos/UnoRfl/unorfl.github.io/pages -f "source[branch]=main" -f "source[path]=/" >nul 2>nul

echo.
echo ============================================
echo   DONE. Live in 1-2 minutes at:
echo   https://unorfl.github.io/
echo ============================================
echo.
pause
exit /b 0

REM ---------- manual path ----------
:MANUAL
echo.
echo [2/3] GitHub CLI not found (or not logged in).
echo.
echo       Create an EMPTY public repo named exactly:
echo.
echo           unorfl.github.io
echo.
echo       at  https://github.com/new
echo       Do NOT tick README, .gitignore or license.
echo.
pause

git remote remove origin >nul 2>nul
git remote add origin https://github.com/UnoRfl/unorfl.github.io.git

echo.
echo       pushing...
git push -u origin main
if errorlevel 1 (
  echo.
  echo [X] Push failed. Most likely the repo does not exist yet,
  echo     or the name is not exactly  unorfl.github.io
  echo.
  pause
  exit /b 1
)

echo.
echo [3/3] One switch left - open this page:
echo.
echo       https://github.com/UnoRfl/unorfl.github.io/settings/pages
echo.
echo       Source: "Deploy from a branch"
echo       Branch: main    Folder: / (root)    then Save
echo.
echo       Then it is live at  https://unorfl.github.io/
echo.
pause
exit /b 0
