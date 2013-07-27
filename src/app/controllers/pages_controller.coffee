locomotive = require 'locomotive'

PagesController = new locomotive.Controller()

PagesController.main = ->
  @title = 'Bastion'
  @render()

module.exports = PagesController
