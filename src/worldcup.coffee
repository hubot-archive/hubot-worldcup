# Description:
#   A way to get basic info and updates on the 2014 World Cup
#
# Configuration:
#   WC_LIVE_PERMITTED_ROOMS - Comma delimited chat room IDs
#
# Commands:
#   hubot wc cards                  - Returns list of suspended players due to cards
#   hubot wc cards <team acronym>   - Returns list of cards for a given team
#   hubot wc gifs <timezone>        - Returns gifs related to matches from today in a given timezone
#   hubot wc gifs recap <timezone>  - Returns gifs related to matches from yesterday in a given timezone
#   hubot wc live <on/off>          - Turns on or off the interval to get score alerts
#   hubot wc group <letter>         - Returns a group's standings
#   hubot wc more <team acronym>    - Returns a link to FIFA to see news, rosters, etc. for a given team
#   hubot wc odds <timezone>        - Returns the odds for the matches yet to be played in given timezone
#   hubot wc recap <timezone>       - Returns a score summary from the previous day's matches in given timezone
#   hubot wc score <timezone>       - Returns the score of the current game in given timezone
#   hubot wc today  <timezone>      - Returns a list of World Cup matches today for a given timezone
#   hubot wc tomorrow <timezone>    - Returns a list of World Cup matches tomorrow for a given timezone
#   hubot wc teams                  - Returns a list of teams in the World Cup
#   hubot wc <red or yellow> <name> - Give someone a red/yellow card
#
# Author:
#   travisvalentine, ccjr

module.exports = (robot) ->
  liveScoreInterval = null

  formatSimpleArray = (msg, array, method, header_string, empty_message=null) ->
    if array.length > 0
      objects = array.map (obj) ->
        obj[method]

      if header_string?
        objects.unshift(header_string)

      formatted_object_string = objects.join("\n")

      msg.send formatted_object_string
    else if empty_message?
      msg.send empty_message

  robot.respond /(worldcup|wc)( today)( [\w \(\&\)\/]+)?/i, (msg) ->
    timezone = if msg.match[3]
      escape msg.match[3].trim()
    else
      ""

    url = "http://worldcup2014bot.herokuapp.com/matches?timezone=#{timezone}"

    msg.http(url)
      .get() (err, res, body) ->
        matches = JSON.parse(body).matches

        formatSimpleArray(msg, matches, "short_description", null, "There are no matches today")

  robot.respond /(worldcup|wc)( tomorrow)( [\w \(\&\)\/]+)?/i, (msg) ->
    timezone = if msg.match[3]
      escape msg.match[3].trim()
    else
      ""

    msg.http("http://worldcup2014bot.herokuapp.com/matches/tomorrow?timezone=#{timezone}")
      .get() (err, res, body) ->
        matches = JSON.parse(body).matches

        formatSimpleArray(msg, matches, "short_description", null, "There are no matches tomorrow :(")

  robot.respond /(worldcup|wc)( teams)/i, (msg) ->
    msg.http("http://worldcup2014bot.herokuapp.com/teams")
      .get() (err, res, body) ->
        teams = JSON.parse(body).teams

        formatSimpleArray(msg, teams, "combined_name", "Team Acronym - Team Name", "We had trouble finding the teams")

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

        formatSimpleArray(msg, scores, "score_summary", null, "There were no matches yesterday :(")

  robot.respond /(worldcup|wc)( score)( [\w \(\&\)\/]+)?/i, (msg) ->
    timezone = if msg.match[3]
      escape msg.match[3].trim()
    else
      ""

    msg.http("http://worldcup2014bot.herokuapp.com/scores/now?timezone=#{timezone}")
      .get() (err, res, body) ->
        scores = JSON.parse(body).scores
        if scores.length > 0
          for score in scores
            msg.send score.score_summary
        else
          msg.send "There are no games right now :("

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

  robot.respond /(worldcup|wc)( gifs)( recap)?( [\w \(\&\)\/]+)?/i, (msg) ->
    timezone = if msg.match[4]
      escape msg.match[4].trim()
    else
      ""

    path = if msg.match[3]
      "http://worldcup2014bot.herokuapp.com/gifs/recap?timezone=#{timezone}"
    else
      "http://worldcup2014bot.herokuapp.com/gifs?timezone=#{timezone}"

    msg.http(path)
      .get() (err, res, body) ->
        gifs_array = JSON.parse(body).gifs

        if gifs_array.length > 0
          gifs_array.map (gif_hash) ->
            if gif_hash["links"].length > 0
              msg.send gif_hash["summary"]

              for link in gif_hash["links"]
                msg.send link
        else
          msg.send "There are no gifs for today's matches :("

  robot.respond /(worldcup|wc)( cards)( .*)?/i, (msg) ->
    team_name = msg.match[3]

    if team_name?
      path = "http://worldcup2014bot.herokuapp.com/cards/team?name=#{team_name.trim()}"
    else
      path = "http://worldcup2014bot.herokuapp.com/cards"

    msg.http(path)
      .get() (err, res, body) ->
        cards = JSON.parse(body).cards

        if cards.length > 0
          cards.map (card) ->
            if team_name?
              msg.send "#{card.team} - Yellow: #{card.yellows}, Red: #{card.reds}"
            else
              msg.send "#{card.player} (#{card.team}) - #{card.suspension} for #{card.offense}"
        else
          if team_name?
            msg.send "There are no cards for #{team_name.trim()}. Make sure that's a valid name or acronym."
          else
            msg.send "There are no suspensions from cards :("

  robot.respond /(worldcup|wc)( live)( .*)/i, (msg) ->
    console.log msg.message.user.room
    permitted_rooms = process.env.WC_LIVE_PERMITTED_ROOMS
    return if permitted_rooms and msg.message.user.room not in permitted_rooms

    status = msg.match[3].trim()

    if status == "on"
      liveScoreInterval = setInterval () ->
        msg.http("http://worldcup2014bot.herokuapp.com/scores/live?seconds_ago=2")
          .get() (err, res, body) ->
            scores = JSON.parse(body).scores

            formatSimpleArray(msg, scores, "score_summary", goalMessage())
      , 3000
    else if status == "off" && liveScoreInterval
      clearInterval(liveScoreInterval)
      liveScoreInterval = null
      msg.send "Live score is off"

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
