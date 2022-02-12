'use strict';

var _generateUUID = function () {
    return uuid.v4()
}

const Directions = {
    NONE: -1,
    UP: 0,
    RIGHT: 1,
    DOWN: 2,
    LEFT: 3
}

const DisplayType = {
    NONE: 0,
    PLAYER: 1,
    GHOST: 2,
    ITEM: 3
}

const MapType = {
    NONE: 0,
    WALL: " ",
    COIN: ".",
    GHOST: "G",
    PLAYER: "P"
}

function Position(x, y) {
  this.x = x
  this.y = y
}

var _ = require('lodash'),
fs = require("fs"),
uuid = require('node-uuid'),
WebSocketServer = require('ws').Server,
wss = new WebSocketServer({ port: 9001 }),
games = {},
gamesWaitingForPlayers = {},
mapsDir = './maps',
GAME_TICK_LENGTH = 200, //ms
MAX_PLAYERS = 2, // static for now but can easily change..
bigMap = require('./maps/oldSchoolStarringJackBlack.json'),
smallMap = require('./maps/mini.json'),
availableMaps = {
    'old school': bigMap,
    mini: smallMap
},
mapsToShowJoinedClients = {
    'old school': _.map(bigMap.map, function(arr) {
        return _.map(arr, function(elem) {
            if(elem === MapType.WALL) {
                return MapType.WALL
            }
            else {
                return MapType.COIN
            }
        })
    }),
    mini: _.map(smallMap.map, function(arr) {
        return _.map(arr, function(elem) {
            if(MapType.WALL === elem) {
                return MapType.WALL
            }
            else {
                return MapType.COIN
            }
        })
    })
}

var getMap = function (mapName) {
    var mapData = _.cloneDeep(availableMaps[mapName]),
    meta = {
        maxGhosts: 0,
        maxPlayers: 0,
        ghostIndices: [],
        playerIndices: []
    }

    _.forEach(mapData.map, function (row, rowIndex) {

        _.forEach(row, function (cell, cellIndex) {

            if (cell === MapType.GHOST) {
                mapData.map[rowIndex][cellIndex] = MapType.GHOST
                meta.maxGhosts++
                meta.ghostIndices.push([rowIndex, cellIndex])
            }
            else if (cell === MapType.PLAYER) {
                mapData.map[rowIndex][cellIndex] = MapType.COIN
                meta.maxPlayers = meta.maxPlayers + 1
                meta.playerIndices.push([rowIndex, cellIndex])
            }
        })
    })

    var i = {
        name: mapName,
        data: mapData,
        meta: meta
    }

    return i
}

var addPlayerToGameQueue = function (map, uuid, ws, game_id) {

    if (_.isEmpty(gamesWaitingForPlayers[map])) {
        var game_id = _.isString(game_id) ? game_id : _generateUUID()

        ws.game_id = game_id
        ws.send(JSON.stringify({
                                   info: {
                                       uuid: uuid
                                   }
                               }))

        gamesWaitingForPlayers[map] = {
            game_id: game_id,
            players: [uuid],
            map_name: map,
            data: _.cloneDeep(getMap(map) )//readMapFromFile(map)
        }
    }
    else { // other players are also waiting to join a game on this map
        gamesWaitingForPlayers[map].players.push(uuid)

        if (gamesWaitingForPlayers[map].players.length >= MAX_PLAYERS) {
            console.log('There are ' + MAX_PLAYERS + ' people waiting to play on map ' + map + ', moving these players over...')

            var gameInfo = _.cloneDeep(gamesWaitingForPlayers[map]),
            infoToReturn = {
                map_name: map,
                map_data: gameInfo.data.data.map,
                game_id: gameInfo.game_id,
                players: _.reduce(_.map(gameInfo.players, function (uuid, index) {
                    return {
                        uuid: uuid,
                        type: 1,
                        state: "player",
                        style: index,
                        score: 0,
                        is_alive: true,
                        x: gameInfo.data.meta.playerIndices[index][1],
                        y: gameInfo.data.meta.playerIndices[index][0],
                        moving: false,
                        direction: Directions.NONE,
                        requestedDirection: Directions.NONE
                    }
                }), function (resultingObj, playerObj) {
                    resultingObj[playerObj.uuid] = playerObj

                    return resultingObj
                }, {}),
                ghosts: _.reduce(_.map(gameInfo.data.meta.ghostIndices, function (ghostXY, index) {
                    return {
                        uuid: _generateUUID(),
                        type: 2,
                        state: "",
                        style: index,
                        is_alive: true,
                        x: ghostXY[1],
                        y: ghostXY[0],
                        dx: 0,
                        dy: 1,
                        moving: true
                    }
                }), function (resultingObj, ghostObj) {
                    resultingObj[ghostObj.uuid] = ghostObj

                    return resultingObj
                }, {})
            }

            delete gamesWaitingForPlayers[map]

            games[infoToReturn.game_id] = infoToReturn

            ws.game_id = infoToReturn.game_id // set the websocket.game_id so what we can loop through all of our websockets, look at the socket.game_id then know to send them that exact game
        }
    }
}

var validPosition = function(position, map) {
    var valid = false

    var x = position.x
    var y = position.y

    if (x >= 0 && x < map[0].length && y >= 0 && y < map.length) {
        valid = map[y][x] !== MapType.WALL
    }

    return valid
}

// Loop through ever websock and send the game info
// This is the loop where we will be updating players positions..
setInterval(function () {

    // Loop through games and update player/ghost positions
    _.forEach(games, function (game) {
        var map = game.map_data,
        players = game.players,
        ghosts = game.ghosts,
        entities = _.assign({}, players, ghosts),
        whatsThere

        _.forEach(entities, function (entity) {

            if (entity.type === DisplayType.PLAYER &&
                    entity.is_alive &&
                    (entity.direction !== Directions.NONE ||
                     entity.requestedDirection !== Directions.NONE)) {
                entity.moving = false
                var dX = 0,
                dY = 0

                switch (entity.requestedDirection) {
                case Directions.UP:    dY = -1; break
                case Directions.RIGHT: dX =  1; break
                case Directions.DOWN:  dY =  1; break
                case Directions.LEFT:  dX = -1; break
                }

                var requestedPosition = new Position(entity.x + dX, entity.y + dY)

                if (validPosition(requestedPosition, map)) {
                    entity.moving = true
                    entity.whatWillBeInSpaceAfterMoving = map[requestedPosition.y][requestedPosition.x]

                    map[entity.y][entity.x] = entity.whatWillBeInSpaceAfterMoving || MapType.COIN

                    entity.x = requestedPosition.x
                    entity.y = requestedPosition.y

                    map[entity.y][entity.x] = 'S'

                    entity.direction = entity.requestedDirection
                }
                else {
                    dX = 0
                    dY = 0

                    switch (entity.direction) {
                    case Directions.UP:    dY = -1; break
                    case Directions.RIGHT: dX =  1; break
                    case Directions.DOWN:  dY =  1; break
                    case Directions.LEFT:  dX = -1; break
                    }

                    requestedPosition = new Position(entity.x + dX, entity.y + dY)

                    if (validPosition(requestedPosition, map)) {
                        entity.moving = true
                        entity.whatWillBeInSpaceAfterMoving = map[requestedPosition.y][requestedPosition.x]

                        map[entity.y][entity.x] = entity.whatWillBeInSpaceAfterMoving || MapType.COIN

                        entity.x = requestedPosition.x
                        entity.y = requestedPosition.y

                        map[entity.y][entity.x] = 'S'
                    }
                }
            }
            else if (entity.type === DisplayType.GHOST) {
                var currentDX = entity.dx,
                currentDY = entity.dy,
                oldX = entity.x,
                oldY = entity.y,
                newX = oldX + currentDX,
                newY = oldY + currentDY,
                whatsInNewSpace

                // Find what's around.

                var leftPosition  = new Position(entity.x - 1, entity.y)
                var rightPosition = new Position(entity.x + 1, entity.y)
                var upPosition    = new Position(entity.x, entity.y - 1)
                var downPosition  = new Position(entity.x, entity.y + 1)

                var validPositionList = []

                if (validPosition(leftPosition, map)) {
                    validPositionList.push(Directions.LEFT)
                }

                if (validPosition(rightPosition, map)) {
                    validPositionList.push(Directions.RIGHT)
                }

                if (validPosition(upPosition, map)) {
                    validPositionList.push(Directions.UP)
                }

                if (validPosition(downPosition, map)) {
                    validPositionList.push(Directions.DOWN)
                }

                // Find the next space you're going to occupy if you keep moving forward.

                var forwardSpace

                if (entity.dx === -1) {
                    forwardSpace = Directions.LEFT
                }
                else if (entity.dx === 1) {
                    forwardSpace = Directions.RIGHT
                }
                else if (entity.dy === -1) {
                    forwardSpace = Directions.UP
                }
                else if (entity.dy === 1) {
                    forwardSpace = Directions.DOWN
                }

                // Start picking a new space.

                var newSpace

                var isHallwaySpace = validPositionList.length < 3
                var allowedToMoveForward = validPositionList.includes(forwardSpace)

                if (isHallwaySpace && allowedToMoveForward) {

                    // Go the direction you're going.

                    newSpace = forwardSpace
                }
                else {

                    // Start picking a random open space.

                    // Filter out the direction you were previously going.

                    var previousSpace

                    switch (forwardSpace) {
                    case Directions.LEFT:  previousSpace = Directions.RIGHT; break
                    case Directions.RIGHT: previousSpace = Directions.LEFT; break
                    case Directions.UP:    previousSpace = Directions.DOWN; break
                    case Directions.DOWN:  previousSpace = Directions.UP; break
                    }

                    validPositionList = validPositionList.filter(e => e !== previousSpace)

                    // Pick a random open space from what's left.

                    newSpace = validPositionList[_.random(0, validPositionList.length - 1)]
                }

                // Updating dx dy to move to new space.

                entity.dx = 0
                entity.dy = 0

                switch (newSpace) {
                case Directions.LEFT:  entity.dx = -1; break
                case Directions.RIGHT: entity.dx =  1; break
                case Directions.UP:    entity.dy = -1; break
                case Directions.DOWN:  entity.dy =  1; break
                }

                entity.direction = newSpace

                // Actually move the ghost
                // Want to add an attribute called "what to redraw" so it draws food or no food for example
                newX = entity.x + entity.dx
                newY = entity.y + entity.dy

                whatsInNewSpace = map[newY][newX]

                map[entity.y][entity.x] = entity.whatWillBeInSpaceAfterMoving || MapType.COIN

                entity.x = newX
                entity.y = newY
                entity.whatWillBeInSpaceAfterMoving = whatsInNewSpace

                map[newY][newX] = 'G'

                console.log(whatsInNewSpace)

                if ('S' === whatsInNewSpace || 'S' === map[entity.y][entity.x]) {
                    console.log('player died')

                    entity.whatWillBeInSpaceAfterMoving = '#'

                    // Find what player is in this spot, then send them a message over WS saying they died

                    var playerWhoDied = _.filter(game.players, function(pl) {
                        return pl.x === newX && pl.y === newY
                    })[0]

                    playerWhoDied.is_alive = false
                }
                else if ("G" === whatsInNewSpace) {
                    console.log('ghost died')
                }
            }
        })
    })

    if (!_.isEmpty(games)) {

        wss.clients.forEach(function (socket) {
            var game = games[socket.game_id]

            try {
                socket.send(JSON.stringify({
                                               objects: game,
                                               uuid: socket.uuid
                                           }))
            }
            catch (err) {
                // TODO what does this mean.. should we remove the player or something..
            }
        })
    }
}, GAME_TICK_LENGTH)

wss.on('connection', function (ws) {
    ws.uuid = _generateUUID()
    ws.already_joined = false // only add them to a game once.. worry about disconnect or w/e later on..
    ws.send(JSON.stringify({
                               maps: mapsToShowJoinedClients
                           }))

    ws.on('message', function (message) {
        console.log("Message from socket with uuid", ws.uuid, ":/n", JSON.stringify(message))

        try {
            var obj = JSON.parse(message)

            if (_.has(obj, 'command')) {

                switch (obj.command) {
                case "join":
                    if (!ws.already_joined) {
                        ws.already_joined = true
                        var map = !_.isEmpty(availableMaps[obj.map]) ? obj.map : 'old school'
                        addPlayerToGameQueue(map, ws.uuid, ws, obj.game_id) // pass in ws so that we can set ws.game_id once that is determined.. this is kind of a hack but I see no harm :)
                    }
                    break
                case "list":
                    var serverInfo = _.mapValues(games, function (gameObj) {
                        return {
                            game_id: gameObj.game_id,
                            map_name: gameObj.map_name,
                            number_of_players: _.keys(gameObj.players).length
                        }
                    })

                    ws.send(JSON.stringify({ info: serverInfo }))
                    break
                default:
                    if (_.has(games, ws.game_id)) {
                        var game = games[ws.game_id],
                        player = game.players[ws.uuid]

                        player.requestedDirection = parseInt(obj.command)
                    }
                    break
                }
            }
        }
        catch (e) {
            console.log(e)
        }
    })
})
