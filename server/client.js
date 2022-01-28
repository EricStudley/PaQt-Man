'use strict';
const WebSocket = require('ws');
var _ = require('lodash');
var keypress = require('keypress');

// make `process.stdin` begin emitting "keypress" events
keypress(process.stdin);


const ws1 = new WebSocket('ws://localhost:9001');

var drawMap = function(map) {
  console.log('\n\n\n\n\n\n\n\n\n\n\n');
  _.forEach(map, function(line) {
    console.log(line.join(''));
  });
};

ws1.on('open', function open() {
  ws1.send(JSON.stringify({command: 'join', map: 'mini'}));
});
ws1.sendo = function(obj) {
  ws1.send(JSON.stringify(obj));
};

ws1.on('message', function incoming(data) {
  var parsed = JSON.parse(data, null, 2);
  if(_.has(parsed, 'everything.map_data')) {
    drawMap(parsed.everything.map_data);
    // console.log(parsed.everything)
  }
  if(_.has(parsed, 'everything.players')) {
    console.log('score');
    _.each(parsed.everything.players, function(player) {
      console.log(player.player_number + ': ' + player.score);
    });
  }
});
const ws2 = new WebSocket('ws://localhost:9001');

ws2.on('open', function open() {
  ws2.send(JSON.stringify({command: 'join', map: 'miniii'}));
});
ws2.sendo = function(obj) {
  ws2.send(JSON.stringify(obj));
}
ws2.on('close', function () {
  process.exit(0);
});
//
// listen for the "keypress" event
process.stdin.on('keypress', function (ch, key) {
  // console.log('got "keypress"', key);
  if ( key.name == 'left') {
    ws1.sendo({command: 'left'});
  }
  if ( key.name == 'right') {
    ws1.sendo({command: 'right'});
  }
  if ( key.name == 'up') {
    ws1.sendo({command: 'up'});
  }
  if ( key.name == 'down') {
    ws1.sendo({command: 'down'});
  }
  if ( key.name == 'q') {
    process.exit(9);
  }
});
// var commands = ['up', 'down', 'left', 'right'];
// setInterval(function() {
//   ws2.sendo({command:commands[Math.floor(Math.random() * 4)] });
// }, 1000);

process.stdin.setRawMode(true);
process.stdin.resume();
