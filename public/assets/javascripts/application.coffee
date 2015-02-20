$('form').submit (e) ->
  e.preventDefault()
  url = $(@).attr 'action'
  method = $(@).attr 'method'
  enctype = $(@).attr 'enctype'
  button = $('input[type=submit]', @)
  button.val('Processing...').attr('disabled', 'disabled')
  formData = new FormData()
  module = $('#module')[0].files[0]
  patch = $('#patch')[0].files[0]
  formData.append('module', module)
  formData.append('patch', patch)

  $.ajax
    url: url
    type: method
    contentType: enctype
    processData: false
    data: formData
    success: (data) ->
      $("#output").text(data.output)
      $('.btn-success').attr('href', "/download/#{data.file}").removeClass('hidden')
    error: ->
      $("#output").html('<h1>Something went wrong!</h1>')
    complete: ->
      button.val('Patch!').removeAttr('disabled')
  @
