#!/usr/bin/env node

var exec = require('child_process').exec;
function puts(err, stderr, stdout) {
  if(err) {
    console.log("error: " + stderr); 
  }
}

var amqp = require('amqplib/callback_api');

var args = process.argv.slice(2);

if (args.length == 0) {
  console.log("Usage: display_control_sub.js <displayname>");
  process.exit(1);
}

var Commands = ['POWER_ON', 'POWER_OFF'];
exec('irsend LIST samsung ""', function(err, stdout, stderr) {
  // not sure why this comes out in stderr...
  stderr.split("\n").forEach(function(line) {
    parts = line.split(" ");
    if(parts[2]) {
      Commands.push(parts[2]);
    }
  });
});

var hostname;
exec('hostname', function(err, stdout, stderr) {
  hostname = stdout;
});

amqp.connect('amqp://10.0.2.101', function(err, conn) {
  conn.createChannel(function(err, ch) {
    var ex = 'display_control';

    ch.assertExchange(ex, 'topic', {durable: false});

    ch.assertQueue('', {exclusive: true}, function(err, q) {
      console.log(' [*] Waiting for logs. To exit press CTRL+C');

      args.forEach(function(key) {
        ch.bindQueue(q.queue, ex, key);
      });
      ch.bindQueue(q.queue, ex, 'all');

      ch.consume(q.queue, function(msg) {
        cmd = msg.content.toString();
        if(cmd == "POWER_ON" || cmd == "POWER_OFF") {
          if(cmd == "POWER_ON") {
            exec('sudo /bin/monitor.sh on', puts);
          }
          else {
            exec('sudo /bin/monitor.sh off', puts);
          }
          console.log(" [x] %s:'%s'", msg.fields.routingKey, cmd);
        }
        else if(Commands.indexOf(cmd) >= 0) {
          exec('irsend SEND_ONCE samsung ' + cmd, puts);
          console.log(" [x] %s:'%s'", msg.fields.routingKey, cmd);
        }
        else {
          console.log(" [x] Command not found, ignoring:'%s'", cmd);
        }
      }, {noAck: true});
    });
  });
});
