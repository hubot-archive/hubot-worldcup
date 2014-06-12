# Description:
#   A way to get basic info and updates on the 2014 World Cup
#
# Commands:
#   hubot wc today                - Returns a list of World Cup matches today
#   hubot wc tomorrow             - Returns a list of World Cup matches tomorrow
#   hubot wc teams                - Returns a list of teams in the World Cup
#   hubot wc more <team acronym>  - Returns a link to FIFA for the team to see news, rosters, etc.

module.exports = (robot) ->
  robot.respond /(worldcup|wc)( today)/i, (msg) ->
    msg.http("http://worldcup2014bot.herokuapp.com/matches")
      .get() (err, res, body) ->
        matches = JSON.parse(body).matches
        if matches.length > 0
          matches_array = matches.map (match) ->
            match.short_description

          formatted_matches = matches_array.join("\n")

          msg.send formatted_matches
        else
          msg.send "There are no matches today"

  robot.respond /(worldcup|wc)( tomorrow)/i, (msg) ->
    msg.http("http://worldcup2014bot.herokuapp.com/matches/tomorrow")
      .get() (err, res, body) ->
        matches = JSON.parse(body).matches
        if matches.length > 0
          matches_array = matches.map (match) ->
            match.short_description

          formatted_matches = matches_array.join("\n")

          msg.send formatted_matches
        else
          msg.send "There are no matches tomorrow :("

  robot.respond /(worldcup|wc)( teams)/i, (msg) ->
    msg.http("http://worldcup2014bot.herokuapp.com/teams")
      .get() (err, res, body) ->
        teams = JSON.parse(body).teams
        if teams.length > 0
          team_names = teams.map (team) ->
            team.combined_name

          # add a quasi header to explain the output
          team_names.unshift("Team Acronym - Team Name")

          formatted_teams = team_names.join("\n")

          msg.send formatted_teams
        else
          msg.send "We had trouble finding the teams"

  robot.respond /(worldcup|wc)( more)( .*)/i, (msg) ->
    team_acronym = msg.match[3]

    msg.http("http://worldcup2014bot.herokuapp.com/links/#{team_acronym}")
      .get() (err, res, body) ->
        msg.send body

  robot.respond /(who).*(win).*(world).*(cup)/i, (msg) ->
    msg.send "BRASIL!!!"
