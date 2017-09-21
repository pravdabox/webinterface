# Pravdabox namespace
P = window.P || {}

#P.ws_endpoint = 'ws://192.168.42.1/ws-bin'
P.ws_endpoint = 'ws://localhost:8080/ws-bin'

P.max_lines = 10

P.dns = ->
    ws = new WebSocket P.ws_endpoint + '/dns'

    c = 0
    ws.onmessage = (event) ->
        $('<div class="l l-' + c + '">' + event.data + '</div>').appendTo '.filter-dns .filterwindow'
        if $('.filter-dns .l').length > P.max_lines
            $('.filter-dns .l-' + (c - P.max_lines)).remove()
        P.scroller()
        c++

P.connections = ->
    ws = new WebSocket P.ws_endpoint + '/connections'

    ws.onmessage = (event) ->
        P.connections_add event.data

        $('.filter-connections').html ''

        c = 0
        for connection in P.connections_bin
            $('<div class="l l-' + c + '">' + connection + '</div>').appendTo '.filter-connections .filterwindow'
            P.scroller()
            c++

P.connections_bin = []
P.connections_add = (connection) ->
    if connection not in P.connections_bin
        P.connections_bin.push connection
    if P.connections_bin.length > 10
        P.connections_bin.shift()

P.http = ->
    ws = new WebSocket P.ws_endpoint + '/http'

    c = 0
    ws.onmessage = (event) ->
        $('<div class="l l-' + c + '">' + event.data + '</div>').appendTo '.filter-http .filterwindow'
        if $('.filter-http .l').length > P.max_lines
            $('.filter-http .l-' + (c - P.max_lines)).remove()
        P.scroller()
        c++

P.cookies = ->
    ws = new WebSocket P.ws_endpoint + '/cookies'

    c = 0
    ws.onmessage = (event) ->
        $('<div class="l l-' + c + '">' + event.data + '</div>').appendTo '.filter-cookies .filterwindow'
        if $('.filter-cookies .l').length > P.max_lines
            $('.filter-cookies .l-' + (c - P.max_lines)).remove()
        P.scroller()
        c++

P.images = ->
    ws = new WebSocket P.ws_endpoint + '/images'

    c = 0
    ws.onmessage = (event) ->
        $('<a href="/image/' + event.data + '" target="_blank"><img class="i i-' + c + '" src="/image/' + event.data + '"></a>').prependTo '.filter-images .filterwindow'
        if $('.filter-images .i').length > P.max_lines
            $('.filter-images .i-' + (c - P.max_lines)).remove()
        P.scroller()
        c++

P.scroller = ->
    $('.filterwindow').animate
        scrollTop: 10000
    , 1

$ ->
    P.dns()
    P.connections()
    P.http()
    P.cookies()
    P.images()
