#!/usr/bin/env bash


cd "$6" || exit



BUILD_DIR="./Builds/$3"

if mountpoint -q "$4"; then
  echo "$4 already mounted"
else
  echo "Mounting SFTP to $4..."
  echo "Sudo password is required to mount the SFTP"
  mkdir -p "$4"
  echo "$3" | sudo sshfs -o password_stdin -o allow_other -p "$2" "$1" "$4"
  echo "$4 mounted"
fi

echo "Copying files to $4$5..."
rsync -av --delete "${BUILD_DIR}" "$4$5"
#echo "rsync -av --delete ${BUILD_DIR} $4$5"
echo "Copying files to $4... Done"

printf "\n\n"
echo "Deployed to: $4$5"
