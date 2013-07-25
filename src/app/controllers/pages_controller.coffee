locomotive = require 'locomotive'

PagesController = new locomotive.Controller()

PagesController.main = ->
  @title = 'Loco'
  @render()

module.exports = PagesController
