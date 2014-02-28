path = require 'path'
fs = require 'fs-plus'

module.exports =
class PdfController
  atom.deserializers.add(this)

  @deserialize: ({filePath}) ->
    if fs.isFileSync(filePath)
      new PdfController(filePath)
    else
      console.warn "Could not serialize PDF view for path '#{filePath}' because the file no longer exists"

  constructor: (@filePath) ->

  serialize: ->
    { @filePath, deserializer: @contructor.name }

  getViewClass: ->
    require './pdf-view'

  getTitle: ->
    if @filePath?
      path.basename(@filePath)
    else
      'untitled'

  getUri: ->
    @filePath

  isEqual: (other) ->
    other instanceof PdfController and @getUri() is other.getUri()
