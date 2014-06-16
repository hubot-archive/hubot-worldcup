# Description:
#   A way to get basic info and updates on the 2014 World Cup
#
# Commands:
#   hubot wc today  <timezone>      - Returns a list of World Cup matches today for a given timezone
#   hubot wc tomorrow <timezone>    - Returns a list of World Cup matches tomorrow for a given timezone
#   hubot wc teams                  - Returns a list of teams in the World Cup
#   hubot wc odds <timezone>        - Returns the odds for the matches yet to be played in given timezone
#   hubot wc score <timezone>       - Returns the score of the current game in given timezone
#   hubot wc recap <timezone>       - Returns a score summary from the previous day's matches in given timezone
#   hubot wc group <letter>         - Returns a group's standings
#   hubot wc more <team acronym>    - Returns a link to FIFA to see news, rosters, etc. for a given team
#   hubot wc <red or yellow> <name> - Give someone a red/yellow card

module.exports = (robot) ->
  robot.respond /(worldcup|wc)( today)( [\w \(\&\)\/]+)?/i, (msg) ->
    timezone = if msg.match[3]
      escape msg.match[3].trim()
    else
      ""

    url = "http://worldcup2014bot.herokuapp.com/matches?timezone=#{timezone}"

    msg.http(url)
      .get() (err, res, body) ->
        matches = JSON.parse(body).matches
        if matches.length > 0
          matches_array = matches.map (match) ->
            match.short_description

          formatted_matches = matches_array.join("\n")

          msg.send formatted_matches
        else
          msg.send "There are no matches today"

  robot.respond /(worldcup|wc)( tomorrow)( [\w \(\&\)\/]+)?/i, (msg) ->
    timezone = if msg.match[3]
      escape msg.match[3].trim()
    else
      ""

    msg.http("http://worldcup2014bot.herokuapp.com/matches/tomorrow?timezone=#{timezone}")
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

  robot.respond /(worldcup|wc).*(yellow|red)( .*)/i, (msg) ->
    color = msg.match[2]
    person = msg.match[3].trim()

    if color == "yellow"
      msg.send "http://www.transpoplanner.com/wp-content/uploads/2014/01/b809cfee40_yellow-card1.jpg"
      msg.send "#{person}: one more and you're out"
    else if color == "red"
      msg.send "http://img.thesun.co.uk/aidemitlum/archive/01689/red_main_1689473a.jpg"
      msg.send "#{person}: you're out"

  robot.respond /(worldcup|wc)( recap)( [\w \(\&\)\/]+)?/i, (msg) ->
    timezone = if msg.match[3]
      escape msg.match[3].trim()
    else
      ""

    msg.http("http://worldcup2014bot.herokuapp.com/scores/recap?timezone=#{timezone}")
      .get() (err, res, body) ->
        scores = JSON.parse(body).scores
        if scores.length > 0
          scores_array = scores.map (score) ->
            score.score_summary

          formatted_scores = scores_array.join("\n")

          msg.send formatted_scores
        else
          msg.send "There were no matches yesterday :("

  robot.respond /(worldcup|wc)( score)( [\w \(\&\)\/]+)?/i, (msg) ->
    timezone = if msg.match[3]
      escape msg.match[3].trim()
    else
      ""

    msg.http("http://worldcup2014bot.herokuapp.com/scores/now?timezone=#{timezone}")
      .get() (err, res, body) ->
        score = JSON.parse(body).score
        if score
          msg.send score.score_summary
        else
          msg.send "There is no game right now :("

  robot.respond /(worldcup|wc)( group)( .*)/i, (msg) ->
    group_letter = msg.match[3].trim().toUpperCase()

    msg.http("http://worldcup2014bot.herokuapp.com/groups/#{group_letter}")
      .get() (err, res, body) ->
        standings = JSON.parse(body).groups

        if standings.length > 0
          scores_array = standings.map (gs) ->
            "#{gs.team.name} - #{gs.games_played}GP #{gs.wins}W #{gs.draws}D #{gs.losses}L #{gs.goals_for}GF #{gs.goals_against}GA #{gs.points}PTS"

          scores_array.unshift("Group #{group_letter} standings")

          formatted_standings = scores_array.join("\n")

          msg.send formatted_standings
        else
          msg.send "We couldn't find standings for that group. Please make sure the letter is valid and try again."

  robot.respond /(worldcup|wc)( odds)( [\w \(\&\)\/]+)?/i, (msg) ->
    timezone = if msg.match[3]
      escape msg.match[3].trim()
    else
      ""

    msg.http("http://worldcup2014bot.herokuapp.com/odds?timezone=#{timezone}")
      .get() (err, res, body) ->
        odds_array = JSON.parse(body).odds

        if odds_array.length > 0
          odds_breakdown = odds_array.map (match_odds) ->
            "#{match_odds.home_team} (#{match_odds.home_team_wins}) #{match_odds.away_team} (#{match_odds.away_team_wins}) Draw (#{match_odds.draw})"

          formatted_odds = odds_breakdown.join("\n")

          msg.send formatted_odds
        else
          msg.send "There are no matches today, you gambling machine."

  robot.router.post '/worldcup/goal/:room', (req, res) ->
     room = req.params.room
     json = JSON.parse(req.body.message)
     message = "#{goalMessage()}! #{json.player.name} #{json.minute}': #{json.home_team} (#{json.home_goals}) vs #{json.away_team} (#{json.away_goals})"
     robot.messageRoom room, message
     res.end()

  goalMessage = ->
    array = [5..15]
    os = Array(array[Math.floor(Math.random() * array.length)]).join('O')
    "G#{os}L"
