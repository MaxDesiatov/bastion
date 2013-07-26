requirejs.config
  shim:
    bootstrap:
      deps: ["jquery"]

define ['users'], (users) ->
  console.log "loaded main module, users.x is #{users.x}"
