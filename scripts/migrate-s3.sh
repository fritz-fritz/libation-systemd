#!/usr/bin/env sh
set -e

# only run if migration was requested and the old directory exists
if [ "${MIGRATION_NEEDED:-false}" = "true" ] && [ -d "${MOUNTPOINT}.old" ]; then
  echo "⟳ Migrating ${MOUNTPOINT}.old → s3://${BUCKET}/"
  if rclone copy "${MOUNTPOINT}.old/." :s3:"${BUCKET}" \
       --s3-no-check-bucket --transfers 20; then
    echo "✔ Migration succeeded, removing ${MOUNTPOINT}.old"
    rm -rf "${MOUNTPOINT}.old"
    echo "⟳ Refreshing VFS dir-cache"
    rclone rc vfs/refresh recursive=true || echo "⚠ unable to refresh cache"
  else
    echo "✖ Migration failed, keeping ${MOUNTPOINT}.old"
  fi

  ENVFILE="$HOME/.config/libation-systemd/env"
  sed -i '/^MIGRATION_NEEDED=/d' "$ENVFILE"
  echo "✔ Cleared MIGRATION_NEEDED flag"
fi