class App extends Backbone.Router
  routes:
    '': 'home'
    'about': 'about'

  home: ->
    console?.log 'Going home'
    Session.set 'where', 'home'

  about: ->
    console?.log 'Going about'
    Session.set 'where', 'about'


testUser = ->
  if not Meteor.userLoaded()
    bootbox.alert "You must be logged in order to make changes to the teams database"
    return false
  true
  
$ ->
  $("#ajax-loader").ajaxStart -> $("#ajax-loader").show()
  $("#ajax-loader").ajaxStop -> $("#ajax-loader").hide()


#Meteor.startup = ->
console?.log "Starting client once again from Meteor startup..."

$("#ajax-loader").ajaxStart -> $("#ajax-loader").show()
$("#ajax-loader").ajaxStop -> $("#ajax-loader").hide()

Accounts.ui.config passwordSignupFields: 'USERNAME_AND_EMAIL'

app = new App
Backbone.history.start pushState: true
#app.navigate '', true

Template.navbar.at_home = ->
  if Session.equals('where', 'home') then "active" else ""

Template.navbar.at_about = ->
  if Session.equals('where', 'about') then "active" else ""

Template.main_container.at_home = ->
  Session.equals 'where', 'home'

Template.main_container.at_about = ->
  Session.equals 'where', 'about'

Template.insert_team.events = {
  'click #insert-team-btn': ->
    team_name = $('#txt-team-name').val()
    team_titles = parseInt $('#txt-team-titles').val(), 10
    if not team_name
      bootbox.alert "You must provide a name"
      $('#txt-team-name').focus()
      return false
    if isNaN team_titles
      $('#txt-team-titles').val "0"
      bootbox.alert "You must provide a number for titles"
      $('#txt-team-titles').focus()
      return false
    Teams.insert name: team_name, titles: team_titles
    $('#insert-team').modal 'hide'
    $('#txt-team-name').val('')
    $('#txt-team-titles').val('0')
    false

'click #cancel-team-btn': ->
  $('#insert-team').modal 'hide'
  $('#txt-team-name').val('')
  $('#txt-team-titles').val('0')
  false

}

Template.team_listing.greeting = ->
  'Welcome to Soccer Teams App, regretably no teams available as of now...'

Template.team_listing.teams = ->
  if Teams.find().count() isnt 0
    Teams.find(
      {}
      {
        sort: {titles: -1, name: 1}
      }
    )
  else
    #      console?.log "There are no teams whatsoever..."
    null

Template.team_listing.team_count = ->
    Teams.find().count()

Template.team_listing.titles_won = ->
  total = 0
  teams = Teams.find()
  teams.forEach (team) ->
    total += team.titles
  total

Template.team_listing.events = {
  'click input.add-player' : ->
#      # template data, if any, is available in 'this'
#      team_name = prompt 'Input the name of the team to append'
#      if team_name
#        team_titles = prompt "Input the number of titles won by #{team_name}"
#        if not isNaN(parseInt team_titles)
#          Teams.insert name: team_name, titles: parseInt(team_titles)
    console?.log "About to insert team"
    $('#insert-team').modal backdrop: true, show: true, keyboard: true unless not testUser()

}

Template.team.events = {

  'click td' : (ev) ->
    #console?.log "Clicked on #{@name}: #{$(ev.target).text()}"
    Session.set 'selected_team', @_id

  'dblclick td': (ev) ->
     #ev.cancelBubble?()
     #ev.preventDefault?()
     ###
     team_name = prompt "Input new name for #{@name}", @name
     if team_name
       team_titles = prompt "Input the number of titles won by #{team_name}", @titles
       if not isNaN(parseInt team_titles)
         Teams.update {_id: @_id}, {name: team_name, titles: parseInt(team_titles)}
     ###
     if testUser()
       Session.set 'edit', @_id
       setTimeout(
         ->
           $('input[name=txt-name]').focus()
         0)

  #'blur .team-edit': (ev) ->
  #   console?.log "Now I'm gonna save a team"
  #   Template.team.save @

  'keyup .team-edit': (ev) ->
     #console?.log "Tecla: ", ev.which
     switch  ev.which
       when 27
         Session.set 'edit', null
       when 13
         Template.team.save @

  'click img.delete-team': (ev) ->
     if testUser()
       bootbox.confirm "Are you sure to delete #{@name}?", "No", "Yes", (resp) => Teams.remove @_id if resp

}

Template.team.save = (team) ->
  console?.log "Saving team #{team.name}"
  Teams.update team._id, {$set: {name: $('input.team-edit[name="txt-name"]').val(), titles: parseInt($('input.team-edit[name="txt-titles"]').val())}}
  Session.set 'edit', null

Template.team.maybe_selected = ->
  if Session.equals 'selected_team', @_id
    'team-selected'
  else
    ''

Template.team.is_editing = ->
    Session.equals 'edit', @_id

