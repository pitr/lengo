parametrize = (string) -> string.toLowerCase().replace(/[^a-z0-9\-_]+/ig, '-').replace(/^-+|-+$/,'')

setInterval ->
  $results = $('.result-container')
  $results.scrollTop($results.height())
, 500

random = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min

how_long = (idea) ->
  switch random(1, 2)
    when 1 then "How long in hours would it take to #{idea.title}"
    when 2 then "How many hours would it take to #{idea.title}"

what_else = ->
  switch random(1, 4)
    when 1 then "What else?"
    when 2 then "And what else?"
    when 3 then "What's next?"
    else "Got any more?"

what_tasks_for = (idea) ->
  ->
    switch random(1,4)
      when 1 then "What is one task required to #{idea.title}?"
      when 2 then "What is a task required to #{idea.title}?"
      when 3 then "Name one task required to #{idea.title}?"
      when 4 then "In order to #{idea.title}, what does one need to do?"

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

add_idea_to_results = (idea) ->
  $('.result-container ol').append($("<li>#{idea.title}</li>"))

ask = (message, cb) ->
  play = (sound) ->
    soundManager.play sound.id, onfinish: ->
      $('.fake-speech-button').show()
      $('.speech-button').show().one 'webkitspeechchange', (event) ->
        $('.speech-button').hide()
        $el = $('.speech-button').removeClass('speech-button')
        setTimeout(->
          $el.addClass('speech-button')
        , 1000)
        cb event.originalEvent.results[0]?.utterance

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

ask_for_duration_of = (current_idea, cb) ->
  ask how_long(current_idea), (duration) ->
    current_idea.duration = duration
    cb()

ask_for_components_of = (ideas_to_explore, current_idea = null) ->
  if current_idea
    message = what_else
  else
    if ideas_to_explore.length == 0
      save_ideas()
      render_graph()
      return
    else
      current_idea = ideas_to_explore.shift() #_randomly() ???
      message = what_tasks_for current_idea

  ask message(), (sub_idea_title) ->
    if skip sub_idea_title
      ideas_to_explore.push current_idea
      ask_for_components_of ideas_to_explore
    else if nothing sub_idea_title
      if current_idea.sub_ideas?.length > 0
        ask_for_components_of ideas_to_explore
      else
        ask_for_duration_of current_idea, ->
          ask_for_components_of ideas_to_explore
    else
      current_idea.sub_ideas ||= []
      new_idea = {title: sub_idea_title, priority: current_idea.sub_ideas.length}
      add_idea_to_results new_idea
      current_idea.sub_ideas.push new_idea
      ideas_to_explore.push new_idea
      ask_for_components_of ideas_to_explore, current_idea

@render_graph = ->
  $('svg').children().remove()

  width = 640
  height = 250

  cluster = d3.layout.cluster()
    .size([height, width - 100])
    .children (d) -> d.sub_ideas

  diagonal = d3.svg.diagonal()
      .projection (d) -> [d.y, d.x]

  svg = d3.select("svg")
      .attr
        width: width
        height: height
    .append("g")
      .attr
        transform: "translate(50,0)"

  nodes = cluster.nodes(root_idea)
  links = cluster.links(nodes)

  link = svg.selectAll(".link")
      .data(links)
    .enter().append("path")
      .attr
        class: "link"
        d: diagonal

  node = svg.selectAll(".node")
      .data(nodes)
    .enter().append("g")
      .attr
        class: "node"
        transform: (d) -> "translate(#{d.y},#{d.x})"

  node.append("ellipse")
      .attr
        rx: 45
        ry: 15

  node.append("text")
      .attr
        'alignment-baseline': 'middle'
        'text-anchor': 'middle'
      .text((d) -> d.title)

  d3.select(self.frameElement).style("height", "#{height}px")

@render_gantt = ->
  $result = $(".gantt").children().remove().end()
  left_so_far = 0

  render_idea = (idea) ->
    left = left_so_far
    title = idea.title
    duration = 0
    $el = $("<div class='ganttRow'><div class='ganttTitle'>#{title}</div><div class='ganttItem' style='left:#{left_so_far}px;'></div></div>")
    $el.appendTo($result)
    if idea.sub_ideas
      for sub_idea in idea.sub_ideas
        duration += render_idea(sub_idea)
    else
      # on leaf
      left_so_far += 100 # idea.duration
      duration = 100 # idea.duration
    $el.find('.ganttItem').width("#{duration}px")
    duration
  render_idea(root_idea)


save_ideas = -> $.post '/ideas', {idea: root_idea}

$ ->
  $('.fake-speech-button').hide()
  $('.speech-button').hide()
  $('.menu').hide()
  $('.q_mark').hide()
  $('.break').hide()

  $list   = $('.result-display ol')
  $svg    = $('.result-display svg').hide()
  $gantt  = $('.result-display gantt').hide()

  $('.menu li').click ->
    type = $(@).data('type')
    switch type
      when 'list'
        $list.show()
        $svg.hide()
        $gantt.hide()
      when 'graph'
        $list.hide()
        $svg.show()
        $gantt.hide()
        render_graph()
      when 'gantt'
        $list.hide()
        $svg.hide()
        $gantt.show()
        render_gantt()

  soundManager.setup
    url: '/swf/'
    onready: ->
      $('.speech-button').click ->
        $('.fake-speech-button').hide()
      $('.new-idea-button').click ->
        $(@).hide()
        $('.logo').hide()
        $('.menu').show()
        $('.q_mark').show()
        $('.break').show()
        ask "What would you like to do?", (title) ->
          window.root_idea = {title}
          add_idea_to_results root_idea
          ask_for_components_of [root_idea]
    ontimeout: ->
      alert 'could not be started!'
