locomotive = require 'locomotive'

PagesController = new locomotive.Controller()

PagesController.before 'main', (next) ->
  if not @req.isAuthenticated()
    @redirect '/login'
  else
    next()

PagesController.main = ->
  @render()

PagesController.login = ->
  @render()

PagesController.logout = ->
  @req.logout()
  @redirect '/login'

module.exports = PagesController
