// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the rails generate channel command.
//
//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  var id = store.get('auth_id');
  var key = store.get('auth_secret');

  if (id && key) {
    var msg = 'GET /cable/';
    var mac = CryptoJS.HmacSHA256(msg, key);
    var token = id + ':' + mac;

    App.cable = ActionCable.createConsumer('/cable/?token=' + token);
  }

}).call(this);
