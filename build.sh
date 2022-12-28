#!/usr/bin/env bash

cd "$2" || exit

# Export env vars
APP_DIR="$1"
BUILD_DIR="./Builds/$3"

rm -rf "${BUILD_DIR}"
mkdir "${BUILD_DIR}"

# make builder .env file
echo "APP_NAME=$3" > .env
echo "APP_DIR=$APP_DIR" >> .env
echo "BUILD_DIR=$BUILD_DIR" >> .env


echo "Copying files to build directory..."
# copy the project to the build directory
rsync -a \
--exclude-from="${APP_DIR}"/.buildexclude \
--exclude-from="${APP_DIR}"/.gitignore \
"${APP_DIR}"/ "${BUILD_DIR}"


# copy env.production to .env
cp "${APP_DIR}"/.env.production "${BUILD_DIR}"/.env

# clean storage & bootstrap/cache
find "${BUILD_DIR}"/storage -type f -delete
find "${BUILD_DIR}"/bootstrap/cache -type f -delete

echo "Copying Done"

cd "${BUILD_DIR}" || exit

pwd


# Install composer dependencies
echo "Installing composer dependencies..."
composer install

# Install npm dependencies
echo "Installing npm dependencies..."
npm install

# Build the frontend
echo "Building the frontend..."

rm -rf ./bootstrap/cache/*

npm run build

php artisan cache:clear
php artisan config:clear
php artisan view:clear
php artisan route:clear
php artisan event:clear

php artisan key:generate

php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache

# Create production bundles
echo "Creating production bundles..."

rm -rf ./vendor
rm -rf ./node_modules

composer install --no-dev --optimize-autoloader
npm install --omit=dev

# Remove stuff needed for build
echo "Removing stuff needed for build..."
rm -rf ./postcss.config.js
rm -rf ./tailwind.config.js
rm -rf ./vite.config.js

printf "\n\n\n\n Build complete!\n"