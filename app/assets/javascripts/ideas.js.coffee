parametrize = (string) -> string.toLowerCase().replace(/[^a-z0-9\-_]+/ig, '-').replace(/^-+|-+$/,'')

skipped = []

setInterval ->
  $results = $('.result-container')
  $results.scrollTop($results.height())
, 500

random = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min

what_else = ->
  switch random(1, 5)
    when 1 then "What else?"
    when 2 then "And what else?"
    when 3 then "What's next?"
    when 4 then "Got any more?"
    when 5 then "More?"

what_tasks_for = (idea) ->
  -> "What are the tasks required to #{idea.title}?"

nothing = (message) ->
  message = message.toLowerCase()
  return yes if message.match /nothing/
  return yes if message.match /that is all/
  return yes if message.match /that is it/
  return yes if message.match /that's it/
  return yes if message.match /done/
  return yes if message.match /^no(pe|ne)?$/
  no

skip = (message) ->
  message = message.toLowerCase()
  return yes if message.match /skip/
  return yes if message.match /not now/
  return yes if message.match /pass/
  return yes if message.match /don't know/
  return yes if message.match /do not know/
  no


ask = (message, cb) ->
  play = (sound) ->
    soundManager.play sound.id, onfinish: ->
      $('.fake-speech-button').show()
      $('#speech-button').show().one 'webkitspeechchange', (event) ->
        title = event.originalEvent.results[0]?.utterance
        $('.result-container ol').append($("<li>#{title}</li>"))
        cb title

  $('.question').text(message)
  id = parametrize message
  sound = soundManager.getSoundById(id)
  if sound
    play sound
  else
    soundManager.createSound
      id: id
      url: "/speech/tts?text=#{encodeURIComponent(message)}"
      autoLoad: yes
      autoPlay: no
      volume: 50
      onload: -> play @

ask_for_components_of = (ideas_to_explore, current_idea) ->
  if current_idea
    message = what_else
  else
    if ideas_to_explore.length == 0
      alert('done')
      return
    else
      current_idea = ideas_to_explore.shift() #_randomly() ???
      message = what_tasks_for current_idea

  ask message(), (sub_idea_title) ->
    if skip sub_idea_title
      ideas_to_explore.push current_idea
      ask_for_components_of ideas_to_explore
    else if nothing sub_idea_title
      ask_for_components_of ideas_to_explore
    else
      current_idea.sub_ideas_to_explore ||= []
      new_idea = {title: sub_idea_title}
      current_idea.sub_ideas_to_explore.push new_idea
      ideas_to_explore.push new_idea
      ask_for_components_of ideas_to_explore, current_idea


create_idea = (data, cb) -> $.post '/ideas', {data: data}, cb

$ ->
  $('.fake-speech-button').hide()
  $('#speech-button').hide()

  soundManager.setup
    url: '/swf/'
    onready: ->
      $('.new-idea').click ->
        $(@).hide()
        ask "What's the name of your idea?", (title) ->
          window.root_idea = {title}
          ask_for_components_of [root_idea]
    ontimeout: ->
      alert 'could not be started!'
