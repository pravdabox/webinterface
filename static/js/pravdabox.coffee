# Pravdabox namespace
P = window.P || {}

P.ws_endpoint = 'ws://192.168.42.1/ws-bin'
#P.ws_endpoint = 'ws://localhost:8080/ws-bin'

P.dns = ->
    ws = new WebSocket P.ws_endpoint + '/dns'
    maxlen = 10

    c = 0
    ws.onmessage = (event) ->
        $('<div class="l l-' + c + '">' + event.data + '</div>').appendTo '.filter-dns'
        if $('.filter-dns .l').length > maxlen
            $('.filter-dns .l-' + (c - maxlen)).remove()
        c++

P.connections = ->
    ws = new WebSocket P.ws_endpoint + '/connections'

    ws.onmessage = (event) ->
        P.connections_add event.data

        $('.filter-connections').html ''

        c = 0
        for connection in P.connections_bin
            $('<div class="l l-' + c + '">' + connection + '</div>').appendTo '.filter-connections'
            c++

P.connections_bin = []
P.connections_add = (connection) ->
    if connection not in P.connections_bin
        P.connections_bin.push connection
    if P.connections_bin.length > 10
        P.connections_bin.shift()

P.http = ->
    ws = new WebSocket P.ws_endpoint + '/http'
    maxlen = 10

    c = 0
    ws.onmessage = (event) ->
        $('<div class="l l-' + c + '">' + event.data + '</div>').appendTo '.filter-http'
        if $('.filter-http .l').length > maxlen
            $('.filter-http .l-' + (c - maxlen)).remove()
        c++

P.cookies = ->
    ws = new WebSocket P.ws_endpoint + '/cookies'
    maxlen = 10

    c = 0
    ws.onmessage = (event) ->
        $('<div class="l l-' + c + '">' + event.data + '</div>').appendTo '.filter-cookies'
        if $('.filter-cookies .l').length > maxlen
            $('.filter-cookies .l-' + (c - maxlen)).remove()
        c++

P.images = ->
    ws = new WebSocket P.ws_endpoint + '/images'
    maxlen = 30

    c = 0
    ws.onmessage = (event) ->
        $('<a href="/image/' + event.data + '" target="_blank"><img class="i i-' + c + '" src="/image/' + event.data + '"></a>').prependTo '.filter-images'
        if $('.filter-images .i').length > maxlen
            $('.filter-images .i-' + (c - maxlen)).remove()
        c++

$ ->
    P.dns()
    P.connections()
    P.http()
    P.cookies()
    P.images()
