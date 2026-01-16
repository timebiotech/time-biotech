#!/usr/bin/env bash
set -euo pipefail

# ==== 設定 ====
SRC="$HOME/Antigravity"
DST="$HOME/timebiotech-site"

# 同期対象（必要に応じて絞る）
SYNC_SRC_DIRS=("src" "public")

# rsync除外（触ってはいけないもの）
RSYNC_EXCLUDES=(
  "--exclude=.git"
  "--exclude=node_modules"
  "--exclude=dist"
  "--exclude=.astro"
  "--exclude=.DS_Store"
)

echo "== Sync from: $SRC  ->  to: $DST =="

# ==== 安全確認 ====
test -d "$SRC" || { echo "ERROR: SRC not found: $SRC"; exit 1; }
test -d "$DST/.git" || { echo "ERROR: DST is not a git repo: $DST"; exit 1; }

# ==== Dry-run（まず削除が出るか見える） ====
echo "== [DRY-RUN] rsync preview =="
for d in "${SYNC_SRC_DIRS[@]}"; do
  test -d "$SRC/$d" || { echo "ERROR: missing $SRC/$d"; exit 1; }
  test -d "$DST/$d" || { echo "ERROR: missing $DST/$d"; exit 1; }

  rsync -av --delete --dry-run \
    "${RSYNC_EXCLUDES[@]}" \
    "$SRC/$d/" "$DST/$d/"
done

echo ""
echo "Dry-run finished."
echo "If the above looks OK, re-run with: $0 --apply"
echo ""

# ==== Apply mode ====
if [[ "${1:-}" != "--apply" ]]; then
  exit 0
fi

echo "== [APPLY] rsync apply =="
for d in "${SYNC_SRC_DIRS[@]}"; do
  rsync -av --delete \
    "${RSYNC_EXCLUDES[@]}" \
    "$SRC/$d/" "$DST/$d/"
done

echo "== npm install/build =="
cd "$DST"
npm ci
npm run build

echo "== git status/diff summary =="
git status
git diff --stat

echo ""
echo "Done. If everything looks good:"
echo "  git add -A"
echo "  git commit -m \"Update site content\""
echo "  git push origin main"

