express = require 'express'

module.exports = ->
  @use express.errorHandler()
