parametrize = (string) -> string.toLowerCase().replace(/[^a-z0-9\-_]+/ig, '-').replace(/^-+|-+$/,'')

ask = (message) ->
  sound = soundManager.createSound
    id: parametrize message
    url: "/speech/tts?text=#{encodeURIComponent(message)}"
    autoLoad: yes
    autoPlay: no
    volume: 50
    onload: ->
      soundManager.play @id

$ ->
  $('.fake-speech-button').hide()
  $('#speech-button').hide()

  soundManager.setup
    url: '/swf/'
    onready: ->
      $('.new-idea').click ->
        $(@).hide()
        ask "What's the name of your idea?"
        $('.fake-speech-button').show()
        $('#speech-button').show().on 'webkitspeechchange', (event) ->
          console.log event
          console.log event.originalEvent.results[0]?.utterance
    ontimeout: ->
      alert 'could not be started!'
