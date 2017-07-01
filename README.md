## Features

* Heroku / postgres ready
* `HTTPS` only, `HTTP` requests are rejected
* Script for quick change of crypto.json keys

## What's included

Public routes:

* `GET` `/`, `/hello`, `/hello/name`
* * hello routes for quick tests
* `wss://host/ws`
* * a websocket connection, will reverse and return whatever you send it

Auth routes:

* `POST` /register 
* * send `username` and `password` as form-data
* `POST` /login 
* * send credentials as HTTP basic auth
* `POST` /logout
* * auth protected, removes token

Token protected:

* `GET` /me 
* * will return current username
* `GET` /users
* * will return list of all users

## Deploy

There's an option to use `vapor toolbelt`, but I prefer to do this manually:

* prepare heroku app
* * create app
* * add postgres database
* * settings - add vapor buildpack: https://github.com/vapor-community/heroku-buildpack
* git clone this repo to your mac
* generate crypto keys by running `./crypto.sh`
* git remote add heroku \<your heroku app url\> 
* git push heroku master

## Contribution

Contributions are welcome! Please just open an issue or send a pull request.
