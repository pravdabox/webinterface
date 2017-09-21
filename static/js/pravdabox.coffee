# Pravdabox namespace
P = window.P || {}

P.ws_endpoint = 'ws://192.168.42.1/ws-bin'
#P.ws_endpoint = 'ws://localhost:8080/ws-bin'

P.max_lines = 10
P.howmanycolors = 7

P.dns = ->
    ws = new WebSocket P.ws_endpoint + '/dns'

    c = 0
    ws.onmessage = (event) ->
        line = P.colorize event.data
        $('<div class="l l-' + c + '">' + line + '</div>').appendTo '.filter-dns .filterwindow'
        if $('.filter-dns .l').length > P.max_lines
            $('.filter-dns .l-' + (c - P.max_lines)).remove()
        P.scroller 'dns'
        c++

P.connections = ->
    ws = new WebSocket P.ws_endpoint + '/connections'

    ws.onmessage = (event) ->
        line = P.colorize event.data
        P.connections_add line

        $('.filter-connections .filterwindow').html ''

        c = 0
        for connection in P.connections_bin
            $('<div class="l l-' + c + '">' + connection + '</div>').appendTo '.filter-connections .filterwindow'
            c++
        P.scroller 'connections'

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
        line = P.colorize event.data
        $('<div class="l l-' + c + '">' + line + '</div>').appendTo '.filter-http .filterwindow'
        if $('.filter-http .l').length > P.max_lines
            $('.filter-http .l-' + (c - P.max_lines)).remove()
        P.scroller 'http'
        c++

P.cookies = ->
    ws = new WebSocket P.ws_endpoint + '/cookies'

    c = 0
    ws.onmessage = (event) ->
        line = P.colorize event.data
        $('<div class="l l-' + c + '">' + line + '</div>').appendTo '.filter-cookies .filterwindow'
        if $('.filter-cookies .l').length > P.max_lines
            $('.filter-cookies .l-' + (c - P.max_lines)).remove()
        P.scroller 'cookies'
        c++

P.images = ->
    ws = new WebSocket P.ws_endpoint + '/images'

    c = 0
    ws.onmessage = (event) ->
        $('<a href="/image/' + event.data + '" target="_blank"><img class="i i-' + c + '" src="/image/' + event.data + '"></a>').prependTo '.filter-images .filterwindow'
        if $('.filter-images .i').length > P.max_lines
            $('.filter-images .i-' + (c - P.max_lines)).remove()
        P.scroller 'images'
        c++

P.scroller = (filter) ->
    $('.filter-' + filter + ' .filterwindow').animate
        scrollTop: 10000
    , 1

P.colorize = (block_with_ip) ->
    # strip ip
    block_with_ip = block_with_ip.replace '192.168.23.', ''
    try
        ip = parseInt block_with_ip.split('\t')[0], 10
    catch
        ip = 0

    # set colorstart to green, red is too agressive as default
    #ip = ip + 2

    # position ip on the color wheel
    ip = ip % P.howmanycolors
    hueval = Math.round(ip / P.howmanycolors * 360)

    # append style
    block_with_ip = '<span style="color: hsl(' + hueval + ', 100%, 50%);">' + block_with_ip + '</span>'

    return block_with_ip

$ ->
    P.dns()
    P.connections()
    P.http()
    P.cookies()
    P.images()
