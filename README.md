# Some basics

Copy contains of Example folder to your project folder. (Append .env.example to .env)

### env.production

- APP_ENV=production
- APP_DEBUG=false
- APP_URL=https://example.com
- set the rest based on prod configs (db, mail)

**dont forget to add .htaccess and .buildexclude**
### Then just run the script by `bin/build` in your project folder. 
### `bin/deploy` will deploy the project to your server.

- `bin/deploy -b` will also build the app
### `bin/stage` operates staging docker

- `bin/stage -b` will also build the app