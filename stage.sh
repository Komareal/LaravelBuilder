#!/usr/bin/env bash

# Export env vars
set -o allexport
source .env
set +o allexport

rm -rf "${BUILD_DIR}"
mkdir "${BUILD_DIR}"

echo "Copying files to build directory... Done"
# copy the project to the build directory
rsync -a \
--exclude-from=.buildexclude \
--exclude-from="${APP_DIR}"/.gitignore \
"${APP_DIR}"/ "${BUILD_DIR}"


# copy env.production to .env
cp "${APP_DIR}"/.env.production "${BUILD_DIR}"/.env

# clean storage & bootstrap/cache
find "${BUILD_DIR}"/storage -type f -delete
find "${BUILD_DIR}"/bootstrap/cache -type f -delete


cd "${BUILD_DIR}" || exit

echo "Copying files to build directory... Done"

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