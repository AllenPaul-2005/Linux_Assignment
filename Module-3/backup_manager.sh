#!/bin/bash
source_dir="$1"
backup_dir="$2"
extension="$3"

if [ "$#" -ne 3 ]; then
  exit 1
fi

if [ ! -d "$backup_dir" ]; then
  mkdir -p "$backup_dir" || exit 1
fi

shopt -s nullglob
files=("$source_dir"/*"$extension")

if [ "${#files[@]}" -eq 0 ]; then
  exit 1
fi

export BACKUP_COUNT=0
total_size=0

for file in "${files[@]}"; do
  size=$(stat -c %s "$file")
  echo "$(basename "$file") $size"
done

for file in "${files[@]}"; do
  filename=$(basename "$file")
  dest="$backup_dir/$filename"

  if [ -f "$dest" ]; then
    if [ "$file" -nt "$dest" ]; then
      cp "$file" "$dest"
      ((BACKUP_COUNT++))
      size=$(stat -c %s "$file")
      total_size=$((total_size + size))
    fi
  else
    cp "$file" "$dest"
    ((BACKUP_COUNT++))
    size=$(stat -c %s "$file")
    total_size=$((total_size + size))
  fi
done

{
  echo "Total files processed: $BACKUP_COUNT"
  echo "Total size of files backed up: $total_size"
  echo "Backup directory: $backup_dir"
} > "$backup_dir/backup_report.log"
