# Hubot World Cup

World Cup commands for hubot!

## Installation

Add **hubot-worldcup** to your `package.json` file:

```json
"dependencies": {
  "hubot": ">= 2.5.1",
  "hubot-scripts": ">= 2.4.2",
  "hubot-worldcup": ">= 0.0.0"
}
```

Add **hubot-worldcup** to your `external-scripts.json`:

```json
["hubot-worldcup"]
```

Run `npm install hubot-worldcup`

## Optional Configuration

```
HUBOT_WC_LIVE_PERMITTED_ROOMS
```

## Commands

```
# Commands:
hubot wc cards                  - Returns list of suspended players due to cards
hubot wc cards <team acronym>   - Returns list of cards for a given team
hubot wc gifs <timezone>        - Returns gifs related to matches from today in a given timezone
hubot wc gifs recap <timezone>  - Returns gifs related to matches from yesterday in a given timezone
hubot wc group <letter>         - Returns a group's standings
hubot wc live <on/off>          - Turns on or off the interval to get score alerts
hubot wc more <team acronym>    - Returns a link to FIFA to see news, rosters, etc. for a given team
hubot wc odds <timezone>        - Returns the odds for the matches yet to be played in given timezone
hubot wc recap <timezone>       - Returns a score summary from the previous day's matches in given timezone
hubot wc score <timezone>       - Returns the score of the current game in given timezone
hubot wc today  <timezone>      - Returns a list of World Cup matches today for a given timezone
hubot wc tomorrow <timezone>    - Returns a list of World Cup matches tomorrow for a given timezone
hubot wc teams                  - Returns a list of teams in the World Cup
hubot wc <red or yellow> <name> - Give someone a red/yellow card
```

## Webhooks

In addition to the interval polling from `hubot wc live on`, this includes a webhook for ReplayLastGoal that posts goal announcements and gifs to campfire. If you have your hubot at a public URL, test out your hook here:

    http://replaylastgoal.com/hooks/add

Just choose webhook from the dropdown and enter the URL of your hubot with the `/worldcup/goal/:room` endpoint. Example:

    http://your_url_here.com/worldcup/goal/campfire_room_id

## Contributing

* Fork this repo
* Submit your code to your fork
* Create a pull request from your fork

## API

The API behind this bot is also open source and can be found at:

https://github.com/travisvalentine/worldcup-bot

Feel free to contribute there as well, following the same steps above in `Contributing`
