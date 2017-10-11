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
        line = event.data
        line = P.parse_formdata line
        line = P.colorize line
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

P.parse_formdata = (data) ->
    ip = data.split('\t')[0]
    keys = data.split('\t')[1].split(',')
    values = data.split('\t')[2].split(',')
    f = []
    i = 0
    for key in keys
        if keys[i] != 'method'
            f.push keys[i] + ': ' + '<strong>' + values[i] + '</strong>'
        i++
    form = ip + '\t' + f.join ', '
    return form

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

P.passwords = ->
    ws = new WebSocket P.ws_endpoint + '/passwords'

    ws.onmessage = (event) ->
        line = P.colorize event.data
        if P.passwords_add line
            $('.filter-passwords .filterwindow').html ''
            c = 0
            for password in P.passwords_bin
                $('<div class="l l-' + c + '">' + password + '</div>').appendTo '.filter-passwords .filterwindow'
                c++
            P.scroller 'passwords'

P.passwords_bin = []
P.passwords_add = (password) ->
    if password not in P.passwords_bin
        P.passwords_bin.push password
        if P.passwords_bin.length > P.max_lines
            P.passwords_bin.shift()
        return true
    return false

P.urls = ->
    ws = new WebSocket P.ws_endpoint + '/urls'

    ws.onmessage = (event) ->
        line = P.colorize event.data
        if P.urls_add line
            $('.filter-urls .filterwindow').html ''
            c = 0
            for url in P.urls_bin
                $('<div class="l l-' + c + '">' + url + '</div>').appendTo '.filter-urls .filterwindow'
                c++
            P.scroller 'urls'

P.urls_bin = []
P.urls_add = (url) ->
    if url not in P.urls_bin
        P.urls_bin.push url
        if P.urls_bin.length > P.max_lines
            P.urls_bin.shift()
        return true
    return false

P.firmwareupgrade = ->
    $('#start_firmwareupgrade').click ->
        ws = new WebSocket P.ws_endpoint + '/firmwareupgrade'

        ws.onmessage = (event) ->
            $('<div class="l">' + event.data + '</div>').appendTo '.firmwareupgrade'

        ws.onclose = (event) ->
            $('<div class="l">Writing in process, please wait. Do not turn off your Pravdabox!</div>').appendTo '.firmwareupgrade'
            setInterval ->
                try
                    $.ajax
                        url: 'http://' + location.host
                        success: ->
                            location.href = 'http://' + location.host
            , 1000

        $('#start_firmwareupgrade').remove()
        return false

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

P.map =
    data: null
    markers: []

    fetch_mapdata: (done) ->
        $.get 'static/js/world.json', (data) ->
            P.map.data = data
            done()

    init: ->
        P.map.fetch_mapdata ->
            P.map.update_markers()
            P.map.render()

    render: ->
        P.map.scale_to_window()
        $('.map').html('')
        $('.map').smallworld
            geojson: P.map.data
            zoom: 2
            waterColor: '#021019'
            landColor: '#08304b'
            markers: P.map.markers
            markerSize: 7
            markerColor: '#fe0'

    update_markers: ->
        for i in [1..10]
            lat = -90 + Math.random() * 180
            lng = -180 + Math.random() * 360
            P.map.markers.push [lat, lng]
        P.map.render()

    scale_to_window: ->
        $('.map, .map canvas').css
            width: $(window).width()
            height: $(window).height() - 200

$ ->
    P.dns()
    P.connections()
    P.forms()
    P.cookies()
    P.images()
    P.passwords()
    P.urls()
    P.firmwareupgrade()
    P.map.init()

    $(window).resize ->
        P.map.render()

