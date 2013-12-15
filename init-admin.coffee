#!/usr/bin/env coffee

bcrypt = require 'bcrypt'
cli = require 'commander'
DB = require 'benchdb/api'
Type = require 'benchdb'
colors = require 'colors'
_ = require 'underscore'

dbRoot = "http://127.0.0.1:5984/bastion"
db = new DB dbRoot
userType = new Type db, 'user'

normalFlow = ->
  console.log "This will create an admin account for the database ".cyan +
  "#{ dbRoot }".cyan

  cli.prompt 'Username:'.green + ' ', (username) ->
    cli.password 'Password: '.green, '*', (password) ->
      cli.password 'Repeat password: '.green, '*', (repeatPassword) ->
        if password isnt repeatPassword
          console.log 'Passwords not equal to each other'.red
          process.exit()
        else
          userType.instance false, (err, newUser) ->
            if err?
              console.log "Error while creating new user in database ".red +
                "#{dbRoot}: #{err}".red
              process.exit()
            else
              bcrypt.hash password, 10, (err, hash) ->
                if err?
                  console.log "Error while hashing a password for user".red
                  process.exit()
                else
                  _(newUser.data).extend
                    name: username
                    password: hash
                    group: 'admin'
                  newUser.save (err) ->
                    if err?
                      console.log "Error while saving new user".red
                      process.exit()
                    else
                      console.log "Succesfully created new admin user ".green +
                        "\"#{username}\"".green
                      process.exit()

userType.filterByField 'group', 'admin', (err, users) ->
  if err?
    console.log "Error while connecting to database #{dbRoot}: #{err}".red
  else if users.length > 0
    cli.confirm "There are already one or more admin users in the database ".cyan +
      "#{dbRoot}, do you want to create another one?".cyan + ' ', (ok) ->
        if ok
          normalFlow()
        else
          process.exit()
  else
    normalFlow()
