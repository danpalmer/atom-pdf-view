path = require 'path'
PdfController = require './pdf-controller'

module.exports =
  activate: ->
    console.log 'Registering URI Handler'
    atom.workspace.registerOpener(openUri)

  deactivate: ->
    console.log 'Unregistering URI Handler'
    atom.workspace.unregisterOpener(openUri)

openUri = (uri) ->
  if path.extname(uri) == '.pdf'
    console.log 'Opening PDF'
    new PdfController(uri)
