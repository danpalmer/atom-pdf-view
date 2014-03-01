{$, ScrollView} = require 'atom'
fs = require 'fs'
require '../pdfjs/pdf'

SCALE = 1.5
MENUBAR_HEIGHT = 40

module.exports =
class PdfView extends ScrollView
  @content: ->
    @div class: 'pdf-view', tabindex: 1, =>
      @div class: 'controls-container', =>
        @div class: 'controls', outlet: 'controls', =>
          @div class: 'btn-group', =>
            @button '+', class: 'btn', outlet: 'zoomIn'
            @button '-', class: 'btn', outlet: 'zoomOut'
      @div outlet: 'content', class: 'pdf-content', =>
        @div outlet: 'container', class: 'pdf-container', =>
          @ul outlet: 'pages'

  initialize: (editor) =>
    super

    @currentScale = 1.0

    PDFJS.workerSrc = 'atom://pdf-view/pdfjs/pdf.worker.js'
    console.log 'Initializing Editor'
    fs.readFile editor.getUri(), (err, data) =>
      console.log 'Loaded PDF Data'
      PDFJS.getDocument(this.bufferToUint8Array(data)).then(this.renderPdf, console.error)

    @zoomIn.click () =>
      @currentScale += 0.1
      this.zoomToScale(@currentScale)

    @zoomOut.click () =>
      @currentScale -= 0.1
      this.zoomToScale(@currentScale)

    this.zoomToScale(@currentScale)

    @controls.height(MENUBAR_HEIGHT)
    $(window).resize () =>
      @content.height(this.height() - MENUBAR_HEIGHT)

  renderPdf: (pdf) =>
    console.log 'Parsed PDF'
    i = 0
    while i < pdf.pdfInfo.numPages
      pdf.getPage(i + 1).then (page) =>
        @pages.append this.renderPage(page)
      i++

  renderPage: (page) =>
    console.log 'Rendering Page'
    viewport = page.getViewport(SCALE)

    @canvas = $('<canvas></canvas>')
    canvas = @canvas[0]
    context = canvas.getContext('2d')
    canvas.height = viewport.height
    canvas.width = viewport.width

    @container.height(canvas.height)
    @container.width(canvas.width)

    scale = window.devicePixelRatio

    if scale != 1
      oldWidth = canvas.width
      oldHeight = canvas.height
      canvas.width = oldWidth * scale
      canvas.height = oldHeight * scale
      canvas.style.width = oldWidth + 'px'
      canvas.style.height = oldHeight + 'px'
      context.scale(scale, scale)

    page.render { canvasContext: context, viewport: viewport }
    return $('<li>').html(canvas).addClass('pdf-page')

  zoomToScale: (scale) =>
    @container.css('transform', "scale(#{scale}, #{scale})")
    offset = 20 + ((scale - 1.0) * 600.0)
    @container.css('margin-top', "#{offset}px")

  bufferToUint8Array: (buf) ->
    ab = new ArrayBuffer(buf.length)
    view = new Uint8Array(ab)
    i = 0
    while i < buf.length
      i++
      view[i] = buf[i]
    return view
