#!/usr/bin/env bash
# GitHub Pages 공개 저장소를 생성하고 최초 배포를 준비합니다.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "사용법: $0 <저장소이름>"
  exit 64
fi

repo_name="$1"
if ! [[ "$repo_name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,99}$ ]]; then
  echo "오류: 저장소 이름은 영문·숫자·점·밑줄·하이픈만 사용할 수 있습니다."
  exit 64
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "오류: GitHub CLI(gh)를 찾을 수 없습니다."
  exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "오류: GitHub 로그인이 필요합니다. 먼저 'gh auth login --web --git-protocol https'를 실행하십시오."
  exit 1
fi

user_id="$(gh api user --jq .id)"
user_login="$(gh api user --jq .login)"
user_name="$(gh api user --jq '.name // .login')"
git config --global user.name "$user_name"
git config --global user.email "${user_id}+${user_login}@users.noreply.github.com"
gh auth setup-git

git init -b main
git add README.md .gitignore site .github
git commit -m "Initial GitHub Pages site"
gh repo create "$repo_name" --public --source=. --remote=origin --push

echo
echo "저장소 생성 및 최초 푸시가 완료되었습니다."
echo "공유 주소: https://${user_login}.github.io/${repo_name}/"
echo "배포 상태: https://github.com/${user_login}/${repo_name}/actions"
