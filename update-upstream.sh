#!/usr/bin/env bash
# Sync the course repository into this clone and then into the current work branch.
# Expected remotes:
#   origin   = https://github.com/nroize/syde556-f26.git
#   upstream = https://github.com/celiasmith/syde556-f26.git

set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Run this script from inside the course repository." >&2
  exit 1
fi

if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "No 'upstream' remote found. Configure it first:" >&2
  echo "  git remote add upstream https://github.com/celiasmith/syde556-f26.git" >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "No 'origin' remote found. Configure it to your fork first:" >&2
  echo "  git remote add origin https://github.com/nroize/syde556-f26.git" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Your working tree has changes. Commit or stash them before updating." >&2
  exit 1
fi

start_branch="$(git branch --show-current)"
if [[ -z "$start_branch" ]]; then
  echo "You are in detached HEAD state; switch to your work branch first." >&2
  exit 1
fi

git fetch upstream
git switch master
git merge --ff-only upstream/master
git push origin master

if [[ "$start_branch" != "master" ]]; then
  git switch "$start_branch"
  git merge master
  git push origin "$start_branch"
fi

echo "Upstream course changes are now incorporated."
