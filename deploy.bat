@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set OWNER=UnoRfl
set REPO=unorfl.github.io

echo ============================================
echo   Deploying portfolio to %REPO%
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

echo [1/4] preparing local repository
if not exist .git git init -q
git add index.html README.md deploy.sh deploy.bat >nul 2>nul
git diff --cached --quiet
if errorlevel 1 git commit -q -m "portfolio: Juan Rafael / codename Uno"
git branch -M main
git remote remove origin >nul 2>nul
git remote add origin https://github.com/%OWNER%/%REPO%.git

echo [2/4] checking who git thinks you are
for /f "delims=" %%A in ('git config --get user.name 2^>nul') do set GITNAME=%%A
for /f "delims=" %%A in ('git config --get user.email 2^>nul') do set GITMAIL=%%A
if "!GITNAME!"=="" (
  echo       [!] git has no user.name set. Setting a default.
  git config --global user.name "%OWNER%"
)
if "!GITMAIL!"=="" (
  echo       [!] git has no user.email set. Setting a default.
  git config --global user.email "Improvised30@gmail.com"
)
echo       name : !GITNAME!
echo       email: !GITMAIL!

echo [3/4] checking the remote exists and you can reach it
git ls-remote https://github.com/%OWNER%/%REPO%.git >nul 2>nul
if errorlevel 1 goto NOREMOTE

echo       remote OK
echo [4/4] pushing
git push -u origin main
if errorlevel 1 goto PUSHFAIL

echo.
echo ============================================
echo   PUSHED.
echo.
echo   Last step - open this page and switch Pages on:
echo   https://github.com/%OWNER%/%REPO%/settings/pages
echo.
echo   Source: "Deploy from a branch"
echo   Branch: main     Folder: / (root)     Save
echo.
echo   Then live at:  https://%REPO%/
echo ============================================
echo.
start "" "https://github.com/%OWNER%/%REPO%/settings/pages"
pause
exit /b 0

:NOREMOTE
echo.
echo ============================================
echo   Cannot reach that repository.
echo ============================================
echo.
echo   This means ONE of two things:
echo.
echo   (A) The repo does not exist yet.
echo       Create it - the page is opening now.
echo         Owner : %OWNER%
echo         Name  : %REPO%          ^<-- must match EXACTLY
echo         Public, and tick NOTHING
echo         (no README, no .gitignore, no license)
echo.
echo   (B) Your GitHub username is not "%OWNER%".
echo       Check the URL of your GitHub profile page.
echo       If it differs, tell Claude - the website itself
echo       also reads from that username.
echo.
start "" "https://github.com/new"
echo.
pause
echo.
echo   Retrying...
git ls-remote https://github.com/%OWNER%/%REPO%.git >nul 2>nul
if errorlevel 1 (
  echo.
  echo   [X] Still cannot reach it. Run this and send Claude the output:
  echo.
  echo       git ls-remote https://github.com/%OWNER%/%REPO%.git
  echo.
  pause
  exit /b 1
)
echo   Found it. Pushing...
git push -u origin main
if errorlevel 1 goto PUSHFAIL
echo.
echo   PUSHED. Now switch Pages on:
echo   https://github.com/%OWNER%/%REPO%/settings/pages
echo   Branch: main   Folder: / (root)
start "" "https://github.com/%OWNER%/%REPO%/settings/pages"
pause
exit /b 0

:PUSHFAIL
echo.
echo ============================================
echo   Push failed after reaching the repo.
echo ============================================
echo.
echo   If it mentioned "non-fast-forward" or "rejected",
echo   the repo was created WITH a README. Run this once:
echo.
echo       git push -u origin main --force
echo.
echo   If it asked for a password and rejected it: GitHub does
echo   not accept account passwords over https. Sign in through
echo   the browser window Git opens, or install GitHub CLI
echo   (https://cli.github.com) and run:  gh auth login
echo.
pause
exit /b 1
