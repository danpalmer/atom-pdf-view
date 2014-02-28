{$, ScrollView} = require 'atom'
fs = require 'fs'
require '../pdfjs/pdf'
# require '../pdfjs/pdf.worker'

scale = 1.0

module.exports =
class PdfView extends ScrollView
  @content: ->
    @div class: 'pdf-view', tabindex: 1, =>
      @div outlet: 'container', class: 'pdf-container', =>
        @canvas outlet: 'canvas'

  initialize: (editor) ->
    super

    PDFJS.workerSrc = 'atom://pdf-view/pdfjs/pdf.worker.js'
    console.log 'Initializing Editor'
    fs.readFile editor.getUri(), (err, data) =>
      console.log 'Loaded PDF Data'
      PDFJS.getDocument(this.bufferToUint8Array(data)).then(this.renderPdf, console.error)

  renderPdf: (pdf) =>
    console.log 'Parsed PDF'
    pdf.getPage(1).then(this.renderPage, console.error)

  renderPage: (page) =>
    console.log 'Rendering Page'
    viewport = page.getViewport(scale)

    canvas = @canvas[0]
    context = canvas.getContext('2d')
    canvas.height = viewport.height
    canvas.width = viewport.width

    @container.height(canvas.height)
    @container.width(canvas.width)

    page.render { canvasContext: context, viewport: viewport }

  bufferToUint8Array: (buf) ->
    ab = new ArrayBuffer(buf.length)
    view = new Uint8Array(ab)
    i = 0
    while i < buf.length
      i++
      view[i] = buf[i]
    return view
