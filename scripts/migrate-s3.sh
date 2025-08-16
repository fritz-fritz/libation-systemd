#!/usr/bin/env sh
set -e

# only run if migration was requested and the old directory exists
if [ "${MIGRATION_NEEDED:-false}" = "true" ] && [ -d "${MOUNTPOINT}.old" ]; then
  echo "⟳ Migrating ${MOUNTPOINT}.old → s3://${BUCKET}/"
  if rclone copy "${MOUNTPOINT}.old/." :s3:"${BUCKET}" \
       --s3-no-check-bucket \
       --transfers 20 \
       --fast-list \
       --bwlimit "${UP_LIMIT}:${DOWN_LIMIT}" \
       ; then
    echo "✔ Migration succeeded, removing ${MOUNTPOINT}.old"
    rm -rf "${MOUNTPOINT}.old"
    echo "⟳ Refreshing VFS dir-cache"
    # Refresh VFS cache and confirm OK without dumping JSON
    if resp="$(rclone rc vfs/refresh recursive=true)"; then
      if printf '%s' "$resp" | grep -q '"OK"'; then
        echo "✔ VFS cache refreshed"
      else
        echo "⚠ VFS refresh failed:"
        echo "$resp"
      fi
    else
      echo "⚠ unable to refresh VFS cache (rclone rc error)"
    fi
  else
    echo "✖ Migration failed, keeping ${MOUNTPOINT}.old"
  fi

  ENVFILE="$HOME/.config/libation-systemd/env"
  sed -i '/^MIGRATION_NEEDED=/d' "$ENVFILE"
  echo "✔ Cleared MIGRATION_NEEDED flag"
fi