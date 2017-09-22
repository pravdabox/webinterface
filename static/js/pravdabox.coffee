# Pravdabox namespace
P = window.P || {}

P.ws_endpoint = 'ws://' + location.host + '/ws-bin'

P.max_lines = 20
P.howmanycolors = 7

P.dns = ->
    ws = new WebSocket P.ws_endpoint + '/dns'

    c = 0
    ws.onmessage = (event) ->
        line = P.colorize event.data
        if P.dns_add line
            $('.filter-dns .filterwindow').html ''
            c = 0
            for address in P.dns_bin
                $('<div class="l l-' + c + '">' + address + '</div>').appendTo '.filter-dns .filterwindow'
                c++
            P.scroller 'dns'

P.dns_bin = []
P.dns_add = (address) ->
    if address not in P.dns_bin
        P.dns_bin.push address
        if P.dns_bin.length > P.max_lines
            P.dns_bin.shift()
        return true
    return false

P.connections = ->
    ws = new WebSocket P.ws_endpoint + '/connections'

    ws.onmessage = (event) ->
        line = P.colorize event.data
        if P.connections_add line
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
        if P.connections_bin.length > P.max_lines
            P.connections_bin.shift()
        return true
    return false

P.forms = ->
    ws = new WebSocket P.ws_endpoint + '/forms'

    ws.onmessage = (event) ->
        line = P.colorize event.data
        if P.forms_add line
            $('.filter-forms .filterwindow').html ''
            c = 0
            for form in P.forms_bin
                $('<div class="l l-' + c + '">' + form + '</div>').appendTo '.filter-forms .filterwindow'
                c++
            P.scroller 'forms'

P.forms_bin = []
P.forms_add = (form) ->
    if form not in P.forms_bin
        P.forms_bin.push form
        if P.forms_bin.length > P.max_lines
            P.forms_bin.shift()
        return true
    return false

P.cookies = ->
    ws = new WebSocket P.ws_endpoint + '/cookies'

    ws.onmessage = (event) ->
        line = P.colorize event.data
        if P.cookies_add line
            $('.filter-cookies .filterwindow').html ''
            c = 0
            for cookie in P.cookies_bin
                $('<div class="l l-' + c + '">' + cookie + '</div>').appendTo '.filter-cookies .filterwindow'
                c++
            P.scroller 'cookies'

P.cookies_bin = []
P.cookies_add = (cookie) ->
    if cookie not in P.cookies_bin
        P.cookies_bin.push cookie
        if P.cookies_bin.length > P.max_lines
            P.cookies_bin.shift()
        return true
    return false

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

    # set colorstart
    ip = ip - 2

    # position ip on the color wheel
    ip = ip % P.howmanycolors
    hueval = Math.round(ip / P.howmanycolors * 360)

    # append style
    block_with_ip = '<span style="color: hsl(' + hueval + ', 100%, 80%);">' + block_with_ip + '</span>'

    return block_with_ip

$ ->
    P.dns()
    P.connections()
    P.forms()
    P.cookies()
    P.images()

