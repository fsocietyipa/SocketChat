var app = require('express')();
var http = require('http').Server(app);
var io = require('socket.io')(http);
const pg = require('pg')

var cn = {
    database: 'Chat',
    port: 5432,
    host: 'localhost',
    user: 'postgress',
    password: 'pass'
};


var pool = new pg.Pool(cn);

app.get('/', function(req, res){
    res.send({msg:"Hello, World!"});
});


pool.connect(function (err, client, done) {
  if (err) {
    return console.error('error fetching client from pool', err)
  }
})



io.on('connection', function(socket){
  console.log("New connection", socket.id);
  pool.query('select * from messages', (err, result) => {
    var totalData = [];
    if (err) {
      return console.error('Error executing query', err.stack)
    }
    for (var i = 0; i < result.rows.length; i++) {
      totalData.push({username: result.rows[i].username, message: result.rows[i].message});
    }
    io.emit('chat message', totalData);
  })


    socket.on('chat message', function(msg){
      pool.query('INSERT INTO messages VALUES(\'' + msg.username + '\', \'' + msg.message + '\');', (err, result) => {
        if (err) {
          return console.error('Error executing query', err.stack)
        }
        pool.query('select * from messages', (err, result) => {
          var totalData = [];
          if (err) {
            return console.error('Error executing query', err.stack)
          }
          for (var i = 0; i < result.rows.length; i++) {
            totalData.push({username: result.rows[i].username, message: result.rows[i].message});
          }
          io.emit('chat message', totalData);
        })
      })
    });
})

http.listen(process.env.PORT || 80, function(){
   console.log('listening on *:8080');
});
