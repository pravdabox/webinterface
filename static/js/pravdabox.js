// Generated by CoffeeScript 1.12.3
var P,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

P = window.P || {};

P.ws_endpoint = 'ws://' + location.host + '/ws-bin';

P.max_lines = 20;

P.howmanycolors = 7;

P.dns = function() {
  var c, ws;
  ws = new WebSocket(P.ws_endpoint + '/dns');
  c = 0;
  return ws.onmessage = function(event) {
    var address, j, len, line, ref;
    line = P.colorize(event.data);
    if (P.dns_add(line)) {
      $('.filter-dns .filterwindow').html('');
      c = 0;
      ref = P.dns_bin;
      for (j = 0, len = ref.length; j < len; j++) {
        address = ref[j];
        $('<div class="l l-' + c + '">' + address + '</div>').appendTo('.filter-dns .filterwindow');
        c++;
      }
      return P.scroller('dns');
    }
  };
};

P.dns_bin = [];

P.dns_add = function(address) {
  if (indexOf.call(P.dns_bin, address) < 0) {
    P.dns_bin.push(address);
    if (P.dns_bin.length > P.max_lines) {
      P.dns_bin.shift();
    }
    return true;
  }
  return false;
};

P.connections = function() {
  var ws;
  ws = new WebSocket(P.ws_endpoint + '/connections');
  return ws.onmessage = function(event) {
    var c, connection, j, len, line, ref;
    line = P.colorize(event.data);
    if (P.connections_add(line)) {
      $('.filter-connections .filterwindow').html('');
      c = 0;
      ref = P.connections_bin;
      for (j = 0, len = ref.length; j < len; j++) {
        connection = ref[j];
        $('<div class="l l-' + c + '">' + connection + '</div>').appendTo('.filter-connections .filterwindow');
        c++;
      }
      return P.scroller('connections');
    }
  };
};

P.connections_bin = [];

P.connections_add = function(connection) {
  if (indexOf.call(P.connections_bin, connection) < 0) {
    P.connections_bin.push(connection);
    if (P.connections_bin.length > P.max_lines) {
      P.connections_bin.shift();
    }
    return true;
  }
  return false;
};

P.forms = function() {
  var ws;
  ws = new WebSocket(P.ws_endpoint + '/forms');
  return ws.onmessage = function(event) {
    var c, form, j, len, line, ref;
    line = event.data;
    line = P.parse_formdata(line);
    line = P.colorize(line);
    if (P.forms_add(line)) {
      $('.filter-forms .filterwindow').html('');
      c = 0;
      ref = P.forms_bin;
      for (j = 0, len = ref.length; j < len; j++) {
        form = ref[j];
        $('<div class="l l-' + c + '">' + form + '</div>').appendTo('.filter-forms .filterwindow');
        c++;
      }
      return P.scroller('forms');
    }
  };
};

P.forms_bin = [];

P.forms_add = function(form) {
  if (indexOf.call(P.forms_bin, form) < 0) {
    P.forms_bin.push(form);
    if (P.forms_bin.length > P.max_lines) {
      P.forms_bin.shift();
    }
    return true;
  }
  return false;
};

P.parse_formdata = function(data) {
  var f, form, i, ip, j, key, keys, len, values;
  ip = data.split('\t')[0];
  keys = data.split('\t')[1].split(',');
  values = data.split('\t')[2].split(',');
  f = [];
  i = 0;
  for (j = 0, len = keys.length; j < len; j++) {
    key = keys[j];
    if (keys[i] !== 'method') {
      f.push(keys[i] + ': ' + '<strong>' + values[i] + '</strong>');
    }
    i++;
  }
  form = ip + '\t' + f.join(', ');
  return form;
};

P.cookies = function() {
  var ws;
  ws = new WebSocket(P.ws_endpoint + '/cookies');
  return ws.onmessage = function(event) {
    var c, cookie, j, len, line, ref;
    line = P.colorize(event.data);
    if (P.cookies_add(line)) {
      $('.filter-cookies .filterwindow').html('');
      c = 0;
      ref = P.cookies_bin;
      for (j = 0, len = ref.length; j < len; j++) {
        cookie = ref[j];
        $('<div class="l l-' + c + '">' + cookie + '</div>').appendTo('.filter-cookies .filterwindow');
        c++;
      }
      return P.scroller('cookies');
    }
  };
};

P.cookies_bin = [];

P.cookies_add = function(cookie) {
  if (indexOf.call(P.cookies_bin, cookie) < 0) {
    P.cookies_bin.push(cookie);
    if (P.cookies_bin.length > P.max_lines) {
      P.cookies_bin.shift();
    }
    return true;
  }
  return false;
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

P.passwords = function() {
  var ws;
  ws = new WebSocket(P.ws_endpoint + '/passwords');
  return ws.onmessage = function(event) {
    var c, j, len, line, password, ref;
    line = P.colorize(event.data);
    if (P.passwords_add(line)) {
      $('.filter-passwords .filterwindow').html('');
      c = 0;
      ref = P.passwords_bin;
      for (j = 0, len = ref.length; j < len; j++) {
        password = ref[j];
        $('<div class="l l-' + c + '">' + password + '</div>').appendTo('.filter-passwords .filterwindow');
        c++;
      }
      return P.scroller('passwords');
    }
  };
};

P.passwords_bin = [];

P.passwords_add = function(password) {
  if (indexOf.call(P.passwords_bin, password) < 0) {
    P.passwords_bin.push(password);
    if (P.passwords_bin.length > P.max_lines) {
      P.passwords_bin.shift();
    }
    return true;
  }
  return false;
};

P.urls = function() {
  var ws;
  ws = new WebSocket(P.ws_endpoint + '/urls');
  return ws.onmessage = function(event) {
    var c, j, len, line, ref, url;
    line = P.colorize(event.data);
    if (P.urls_add(line)) {
      $('.filter-urls .filterwindow').html('');
      c = 0;
      ref = P.urls_bin;
      for (j = 0, len = ref.length; j < len; j++) {
        url = ref[j];
        $('<div class="l l-' + c + '">' + url + '</div>').appendTo('.filter-urls .filterwindow');
        c++;
      }
      return P.scroller('urls');
    }
  };
};

P.urls_bin = [];

P.urls_add = function(url) {
  if (indexOf.call(P.urls_bin, url) < 0) {
    P.urls_bin.push(url);
    if (P.urls_bin.length > P.max_lines) {
      P.urls_bin.shift();
    }
    return true;
  }
  return false;
};

P.firmwareupgrade = function() {
  return $('#start_firmwareupgrade').click(function() {
    var ws;
    ws = new WebSocket(P.ws_endpoint + '/firmwareupgrade');
    ws.onmessage = function(event) {
      return $('<div class="l">' + event.data + '</div>').appendTo('.firmwareupgrade');
    };
    ws.onclose = function(event) {
      $('<div class="l">Writing in process, please wait. Do not turn off your Pravdabox!</div>').appendTo('.firmwareupgrade');
      return setInterval(function() {
        try {
          return $.ajax({
            url: 'http://' + location.host,
            success: function() {
              return location.href = 'http://' + location.host;
            }
          });
        } catch (error) {}
      }, 1000);
    };
    $('#start_firmwareupgrade').remove();
    return false;
  });
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

P.map = {
  init: function() {
    var markers;
    markers = [];
    P.map.scale_to_window();
    return $.get('static/js/world.json', function(data) {
      $('.map').smallworld({
        geojson: data,
        zoom: 2,
        waterColor: '#021019',
        landColor: '#08304b'
      });
      return setTimeout(function() {
        var lat, lng;
        $('.map').html('');
        lat = $('.map').data('lat');
        lng = $('.map').data('long');
        markers.push([lat, lng]);
        return $('.map').smallworld({
          geojson: data,
          zoom: 2,
          waterColor: '#021019',
          landColor: '#08304b',
          markers: markers,
          markerSize: 8,
          markerColor: '#fe0'
        });
      }, 10);
    });
  },
  scale_to_window: function() {
    var h, w;
    w = $(window).width();
    h = $(window).height();
    $('.map, .map canvas').css({
      width: w,
      height: h
    });
    return console.info(w, h);
  }
};

$(function() {
  P.dns();
  P.connections();
  P.forms();
  P.cookies();
  P.images();
  P.passwords();
  P.urls();
  P.firmwareupgrade();
  P.map.init();
  return $(window).resize(function() {
    return P.map.init();
  });
});
