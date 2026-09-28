#!/usr/bin/env bash
# HTML 파일 하나를 GitHub Pages의 기본 문서로 배포합니다.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "사용법: $0 /경로/문서.html"
  exit 64
fi

source_file="$1"
if [[ ! -f "$source_file" ]]; then
  echo "오류: HTML 파일을 찾을 수 없습니다: $source_file"
  exit 66
fi
if [[ "${source_file##*.}" != "html" && "${source_file##*.}" != "htm" ]]; then
  echo "오류: .html 또는 .htm 파일만 배포할 수 있습니다."
  exit 65
fi
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1 || ! git remote get-url origin >/dev/null 2>&1; then
  echo "오류: 먼저 ./setup-repo.sh <저장소이름>으로 GitHub 저장소를 연결하십시오."
  exit 1
fi

cp "$source_file" site/index.html
git add site/index.html
if git diff --cached --quiet; then
  echo "변경사항이 없어 배포하지 않았습니다."
  exit 0
fi

git commit -m "Deploy HTML document"
git push origin main
echo "푸시 완료. GitHub Actions 배포가 진행됩니다."
