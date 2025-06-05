#!/bin/bash
##############################################################################
# Script: init_git_repo_push.sh
# Purpose: Clone, initialize, and push files to any GitHub repo (public or private)
# Author: Lab Scripts Elite Edition
# Created: 2025-06-05
# Safe to rerun. Designed for automation, clarity, and GitHub token-based auth.
##############################################################################

set -euo pipefail
LOGFILE="$HOME/git_repo_init.log"
echo "==== 🚀 GitHub Repo Bootstrap Started at $(date) ====" | tee "$LOGFILE"

##############################################################################
# Prompt for Required Info
##############################################################################
read -rp "GitHub Username: " GITHUB_USER
read -rsp "GitHub Personal Access Token (hidden): " GITHUB_PAT
echo
read -rp "Repository Name (e.g., my-scripts): " REPO_NAME
read -rp "Branch name to use [default: main]: " BRANCH
BRANCH=${BRANCH:-main}

REPO_URL="https://$GITHUB_USER:$GITHUB_PAT@github.com/$GITHUB_USER/$REPO_NAME.git"
CLONE_DIR="$HOME/$REPO_NAME"

##############################################################################
# Git Identity Configuration
##############################################################################
read -rp "Your Full Name for Git commits: " GIT_NAME
read -rp "Your Email for Git commits: " GIT_EMAIL

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global credential.helper store

##############################################################################
# Clone, Initialize, Commit
##############################################################################
echo "[*] Cloning repo to $CLONE_DIR..." | tee -a "$LOGFILE"
rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR" | tee -a "$LOGFILE"
cd "$CLONE_DIR"

echo "[*] Creating example files (edit or replace as needed)..." | tee -a "$LOGFILE"
echo "# Hello from $REPO_NAME" > README.md
touch .placeholder

echo "[*] Committing and pushing files to '$BRANCH'..." | tee -a "$LOGFILE"
git add .
git commit -m "Initial commit: README and placeholder"
git branch -M "$BRANCH"
git push -u origin "$BRANCH"

echo "==== ✅ Repo Initialized and Pushed: https://github.com/$GITHUB_USER/$REPO_NAME ====" | tee -a "$LOGFILE"
