#!/usr/bin/env bash
# Automated PostgreSQL backup via pg_dump.
# Usage: bash scripts/backup.sh
# Set BACKUP_DIR env var to custom location (default: ../backups)

set -euo pipefail

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIR="${BACKUP_DIR:-./backups}"
mkdir -p "$BACKUP_DIR"

# Parse DATABASE_URL into parts
# Supports: postgresql://user:password@host:port/db?schema=xxx
URL="${DATABASE_URL:-}"
if [[ -z "$URL" ]]; then
  echo "? DATABASE_URL not set"
  exit 1
fi

OUTPUT="$BACKUP_DIR/${TIMESTAMP}.sql"

echo "?? Backing up to $OUTPUT ..."
pg_dump "$URL" --no-owner --clean --if-exists > "$OUTPUT"
gzip "$OUTPUT"

echo "? Done: ${OUTPUT}.gz ($(du -h "${OUTPUT}.gz" | cut -f1))"

# Keep last 7 backups, delete older
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete
