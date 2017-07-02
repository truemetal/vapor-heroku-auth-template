This repo is a `vapor-2` (a `swift` framework) app template with auth routes, and it's ready to be deployed to `Heroku`
<br><br><br>

## Features

* `Heroku` / `postgres` ready
* `HTTPS` only, `HTTP` requests are rejected
* Script for quick change of crypto.json keys
* Pre-populated with 4 user accounts - `u1`, `u2`, `u3` and `u4`
* * passwod is `123` - same for all of them
* * comes with pre-populated access tokens - `u1 token`, `u2 token`, `u3 token` and `u4 token`

## What's included

#### Public routes:

* `GET` `/`, `/hello`, `/hello/name`
* * hello routes for quick tests
* `wss://host/ws`
* * a websocket connection, will reverse and return whatever you send it

#### Auth routes:

* `POST` /register 
* * send `username` and `password` as form-data
* `POST` /login 
* * send credentials as HTTP basic auth
* `POST` /logout
* * auth protected, removes token

#### Token protected:

* `GET` /me 
* * will return current username
* `GET` /users
* * will return list of all users (except for the one making the request)

## Deploy

There's an option to use `vapor toolbelt`, but I prefer to do this manually:

* prepare heroku app
* * create app
* * add postgres database
* * settings - add vapor buildpack: https://github.com/vapor-community/heroku-buildpack
* `git clone https://github.com/truemetal/vapor-2-heroku-auth-template.git` to your mac
* generate crypto keys by running `./crypto.sh`
* `git commit -am "new crypto keys"`
* `git remote add heroku <your heroku app url>`
* `git push heroku master`

##### and to move it to your github / bitbucket 

* `git remote rm origin`
* `git remote add origin <your repo path>`

## Contribution

Contributions are welcome! Please just open an issue or send a pull request.
