#!/usr/bin/env node

var amqp = require('amqplib/callback_api');

amqp.connect('amqp://10.0.2.101', function(err, conn) {
  conn.createChannel(function(err, ch) {
    var ex = 'display_control';
    var args = process.argv.slice(2);


    if (args.length < 2) {
      console.log("Usage: display_control_pub.js <displayname> <command>");
      process.exit(1);
    }
    var display = args[0];
    var cmd = args[1];

    ch.assertExchange(ex, 'topic', {durable: false});
    ch.publish(ex, display, new Buffer(cmd));
    console.log(" [x] Sent %s: '%s'", display, cmd);
  });

  setTimeout(function() { conn.close(); process.exit(0) }, 500);
});
