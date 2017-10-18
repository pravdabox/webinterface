// Generated by CoffeeScript 1.12.3
var P,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

P = window.P || {};

P.ws_endpoint = 'ws://' + location.host + '/ws-bin';

P.max_lines = 100;

P.max_links = 10;

P.howmanycolors = 7;

P.dns = function() {
  var c, ws;
  ws = new WebSocket(P.ws_endpoint + '/dns');
  c = 0;
  return ws.onmessage = function(event) {
    var address, k, len, line, ref;
    line = P.colorize(event.data);
    if (P.dns_add(line)) {
      $('.widget-dns .filterwindow').html('');
      c = 0;
      ref = P.dns_bin;
      for (k = 0, len = ref.length; k < len; k++) {
        address = ref[k];
        $('<div class="l l-' + c + '">' + address + '</div>').appendTo('.widget-dns .filterwindow');
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
    var c, connection, ip, k, len, line, ref;
    line = P.colorize(event.data);
    if (P.connections_add(line)) {
      ip = event.data.split('\t')[1];
      P.map.ip2location(ip, function() {
        return P.map.update();
      });
      $('.widget-connections .filterwindow').html('');
      c = 0;
      ref = P.connections_bin;
      for (k = 0, len = ref.length; k < len; k++) {
        connection = ref[k];
        $('<div class="l l-' + c + '">' + connection + '</div>').appendTo('.widget-connections .filterwindow');
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
    var c, form, k, len, line, ref;
    line = event.data;
    line = P.parse_formdata(line);
    line = P.colorize(line);
    if (P.forms_add(line)) {
      $('.widget-forms .filterwindow').html('');
      c = 0;
      ref = P.forms_bin;
      for (k = 0, len = ref.length; k < len; k++) {
        form = ref[k];
        $('<div class="l l-' + c + '">' + form + '</div>').appendTo('.widget-forms .filterwindow');
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
  var f, form, i, ip, k, key, keys, len, values;
  ip = data.split('\t')[0];
  keys = data.split('\t')[1].split(',');
  values = data.split('\t')[2].split(',');
  f = [];
  i = 0;
  for (k = 0, len = keys.length; k < len; k++) {
    key = keys[k];
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
    var c, cookie, k, len, line, ref;
    line = P.colorize(event.data);
    if (P.cookies_add(line)) {
      $('.widget-cookies .filterwindow').html('');
      c = 0;
      ref = P.cookies_bin;
      for (k = 0, len = ref.length; k < len; k++) {
        cookie = ref[k];
        $('<div class="l l-' + c + '">' + cookie + '</div>').appendTo('.widget-cookies .filterwindow');
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
    $('<a href="/image/' + event.data + '" target="_blank"><img class="i i-' + c + '" src="/image/' + event.data + '"></a>').prependTo('.widget-images .filterwindow');
    if ($('.widget-images .i').length > P.max_lines) {
      $('.widget-images .i-' + (c - P.max_lines)).remove();
    }
    P.scroller('images');
    return c++;
  };
};

P.passwords = function() {
  var ws;
  ws = new WebSocket(P.ws_endpoint + '/passwords');
  return ws.onmessage = function(event) {
    var c, k, len, line, password, ref;
    line = P.colorize(event.data);
    if (P.passwords_add(line)) {
      $('.widget-passwords .filterwindow').html('');
      c = 0;
      ref = P.passwords_bin;
      for (k = 0, len = ref.length; k < len; k++) {
        password = ref[k];
        $('<div class="l l-' + c + '">' + password + '</div>').appendTo('.widget-passwords .filterwindow');
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
    var c, k, len, line, ref, url;
    line = P.colorize(event.data);
    if (P.urls_add(line)) {
      $('.widget-urls .filterwindow').html('');
      c = 0;
      ref = P.urls_bin;
      for (k = 0, len = ref.length; k < len; k++) {
        url = ref[k];
        $('<div class="l l-' + c + '">' + url + '</div>').appendTo('.widget-urls .filterwindow');
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

P.widgets = function() {
  $('.widget').draggable({
    handle: '.head',
    stack: '.widget'
  });
  return $('.widget').resizable();
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
      }, 5000);
    };
    $('#start_firmwareupgrade').remove();
    return false;
  });
};

P.scroller = function(filter) {
  return $('.widget-' + filter + ' .filterwindow').animate({
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
  markers: [],
  ip_coords: {},
  homeip: null,
  options: {
    map: {
      name: 'world_countries_miller',
      defaultArea: {
        attrs: {
          fill: '#08304b',
          stroke: '#08304b',
          'stroke-width': 0.3
        },
        attrsHover: {
          animDuration: 0,
          fill: '#08304b'
        }
      },
      defaultPlot: {
        attrs: {
          fill: '#ff0',
          stroke: '#000',
          r: 1
        },
        attrsHover: {
          'stroke-width': 0,
          r: 1
        },
        text: {
          attrs: {
            fill: '#fff',
            'font-size': 5
          },
          margin: 1
        }
      },
      defaultLink: {
        attrs: {
          stroke: '#0f0',
          'stroke-width': 0.3
        },
        factor: -0.1
      },
      zoom: {
        enabled: true,
        init: {
          latitude: 50,
          longitude: 0,
          level: 0
        },
        animDuration: 0,
        step: 1,
        maxLevel: 10
      }
    }
  },
  init: function() {
    P.map.homeip = $('.map').data('homeip');
    return P.map.ip2location(P.map.homeip, function() {
      return P.map.render();
    });
  },
  render: function() {
    P.map.scale_to_window();
    return $('.mapcontainer').mapael(P.map.options);
  },
  update: function() {
    var k, len, links, m, plots, ref;
    P.map.scale_to_window();
    plots = {};
    links = {};
    if (P.map.markers.length > P.max_links + 1) {
      P.map.markers.splice(1, 1);
    }
    ref = P.map.markers;
    for (k = 0, len = ref.length; k < len; k++) {
      m = ref[k];
      plots[m.ip] = {
        latitude: m.lat,
        longitude: m.lng,
        tooltip: {
          content: m.ip + "<br /><br />" + m.city_name + "<br />" + m.region_name + "<br />" + m.country_name
        }
      };
      links[P.map.homeip + "-" + m.ip] = {
        between: [P.map.homeip, m.ip]
      };
    }
    return $('.mapcontainer').trigger('update', [
      {
        newPlots: plots,
        newLinks: links,
        deletePlotKeys: 'all',
        deleteLinkKeys: 'all',
        animDuration: 0
      }
    ]);
  },
  ip2location: function(ip, done) {
    if (!P.map.ip_coords[ip]) {
      return $.get('ip2location?ip=' + ip, function(data) {
        var j;
        P.map.ip_coords[ip] = data;
        j = $.parseJSON(data);
        if (j.lat !== 0 && j.lng !== 0) {
          P.map.markers.push(j);
        }
        return done(data);
      });
    } else {
      return done(P.map.ip_coords[ip]);
    }
  },
  scale_to_window: function() {
    return $('.mapcontainer, .mapcontainer .map').css({
      width: $(window).width(),
      height: $(window).height() - 200
    });
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
  P.widgets();
  P.firmwareupgrade();
  P.map.init();
  return $(window).resize(function() {
    return P.map.init();
  });
});
