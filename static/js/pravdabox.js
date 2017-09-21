// Generated by CoffeeScript 1.12.3
(function() {
  var P,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  P = window.P || {};

  P.ws_endpoint = 'ws://192.168.42.1/ws-bin';

  P.max_lines = 10;

  P.howmanycolors = 7;

  P.dns = function() {
    var c, ws;
    ws = new WebSocket(P.ws_endpoint + '/dns');
    c = 0;
    return ws.onmessage = function(event) {
      var address, i, len, line, ref;
      line = P.colorize(event.data);
      P.dns_add(line);
      $('.filter-dns .filterwindow').html('');
      c = 0;
      ref = P.dns_bin;
      for (i = 0, len = ref.length; i < len; i++) {
        address = ref[i];
        $('<div class="l l-' + c + '">' + address + '</div>').appendTo('.filter-dns .filterwindow');
        c++;
      }
      return P.scroller('dns');
    };
  };

  P.dns_bin = [];

  P.dns_add = function(address) {
    if (indexOf.call(P.dns_bin, address) < 0) {
      P.dns_bin.push(address);
    }
    if (P.dns_bin.length > 10) {
      return P.dns_bin.shift();
    }
  };

  P.connections = function() {
    var ws;
    ws = new WebSocket(P.ws_endpoint + '/connections');
    return ws.onmessage = function(event) {
      var c, connection, i, len, line, ref;
      line = P.colorize(event.data);
      P.connections_add(line);
      $('.filter-connections .filterwindow').html('');
      c = 0;
      ref = P.connections_bin;
      for (i = 0, len = ref.length; i < len; i++) {
        connection = ref[i];
        $('<div class="l l-' + c + '">' + connection + '</div>').appendTo('.filter-connections .filterwindow');
        c++;
      }
      return P.scroller('connections');
    };
  };

  P.connections_bin = [];

  P.connections_add = function(connection) {
    if (indexOf.call(P.connections_bin, connection) < 0) {
      P.connections_bin.push(connection);
    }
    if (P.connections_bin.length > 10) {
      return P.connections_bin.shift();
    }
  };

  P.http = function() {
    var c, ws;
    ws = new WebSocket(P.ws_endpoint + '/http');
    c = 0;
    return ws.onmessage = function(event) {
      var line;
      line = P.colorize(event.data);
      $('<div class="l l-' + c + '">' + line + '</div>').appendTo('.filter-http .filterwindow');
      if ($('.filter-http .l').length > P.max_lines) {
        $('.filter-http .l-' + (c - P.max_lines)).remove();
      }
      P.scroller('http');
      return c++;
    };
  };

  P.cookies = function() {
    var c, ws;
    ws = new WebSocket(P.ws_endpoint + '/cookies');
    c = 0;
    return ws.onmessage = function(event) {
      var line;
      line = P.colorize(event.data);
      $('<div class="l l-' + c + '">' + line + '</div>').appendTo('.filter-cookies .filterwindow');
      if ($('.filter-cookies .l').length > P.max_lines) {
        $('.filter-cookies .l-' + (c - P.max_lines)).remove();
      }
      P.scroller('cookies');
      return c++;
    };
  };

  P.images = function() {
    var c, ws;
    ws = new WebSocket(P.ws_endpoint + '/images');
    c = 0;
    return ws.onmessage = function(event) {
      $('<a href="/image/' + event.data + '" target="_blank"><img class="i i-' + c + '" src="/image/' + event.data + '"></a>').prependTo('.filter-images .filterwindow');
      if ($('.filter-images .i').length > P.max_lines) {
        $('.filter-images .i-' + (c - P.max_lines)).remove();
      }
      P.scroller('images');
      return c++;
    };
  };

  P.scroller = function(filter) {
    return $('.filter-' + filter + ' .filterwindow').animate({
      scrollTop: 10000
    }, 1);
  };

  P.colorize = function(block_with_ip) {
    var hueval, ip;
    block_with_ip = block_with_ip.replace('192.168.23.', '');
    try {
      ip = parseInt(block_with_ip.split('\t')[0], 10);
    } catch (error) {
      ip = 0;
    }
    ip = ip - 2;
    ip = ip % P.howmanycolors;
    hueval = Math.round(ip / P.howmanycolors * 360);
    block_with_ip = '<span style="color: hsl(' + hueval + ', 100%, 80%);">' + block_with_ip + '</span>';
    return block_with_ip;
  };

  $(function() {
    P.dns();
    P.connections();
    P.http();
    P.cookies();
    return P.images();
  });

}).call(this);
