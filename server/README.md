# How stuff works

### Install/Run

```
npm install
```

Run server
```
node index.js
```

Run a sample client (run 2 of them in different terminals)
```
node clients/node/client.js
```

### Server
Has an object called `games` which has keys that are game `game_id`s.  The info under each of the `games.game_id` is exactly what is sent across the wire to each websocket client that is involved in that game.

This is what `games` looks like (I had to truncate `map_data`).  In the example of `games` below there is just one `game_id` as a key, `"171e5591-3851-4ae4-bbdc-8dfb7628e7b2"`, but it's 100% possible for there to be more than one game/object/key under `games`.
```
{
  "171e5591-3851-4ae4-bbdc-8dfb7628e7b2": {
    "map_name":"shlomo",
    "map_data":[
      [' ', ' ', ' ']
      ['.', '.', '.']
      ['.', ' ', ' ']
    ],
    "game_id":"171e5591-3851-4ae4-bbdc-8dfb7628e7b2",
    "players":{
      "6058fb79-9595-4c47-a363-ab2f99a32199": {
        "id":"6058fb79-9595-4c47-a363-ab2f99a32199",
        "x":0,
        "y":0,
        "dx":0,
        "dy":0
      },
      6455013e-8330-4e5e-8e99-bdc58c1a0b70": {
        "id":"6455013e-8330-4e5e-8e99-bdc58c1a0b70",
        "x":29,
        "y":0,
        "dx":0,
        "dy":0
      }
    }
  }
}
```

A websocket client gets assigned a `game_id` and a `player_id` which is the same `game_id` and `players.id` you see above (make it easy to associate them).
This makes it very easy to loop over all the clients connected to the "websocket server" and simply send them all the information contained within `games.<websocket_client.game_id>`,  which will send the client the map + player locations for the game that they are playing.

The server is currently processing the following commands/actions

Join a game (100% works)
```
{
  "command": "join"
}
```

```
{
  "command": "join",
  "map": "shlomo"
}
```

```
{
  "command": "join",
  "map": "shlomo",
  "game_id": "server_name_goes_here"
}
```

Move Player (100% works)
```
{
  "command": "up" // "up" "down" "left" "right" are valid choices that will change the characters dx/dy
}
```


### Game Logic/Loop
Right now there is a `setInterval` loop which goes through each game underneath `games` and does the following:

1. It calculates the next position for each player (using the player's `x`, `dx`, `y`, `dy`).  If the player can move to that position (it isn't wall or out of bounds) then their new position is updated.  If the player cannot move to that position, then their `dx` and `dy` are set to 0 (stationary).

2. It then loops through all of the clients connected to the websocket server and uses `game_id` stored on the socket object to easily get the value of `games[socket.game_id]` through that socket over to the client. Example: `socket.send(JSON.stringify({everything: games[socket.game_id]}))`.
