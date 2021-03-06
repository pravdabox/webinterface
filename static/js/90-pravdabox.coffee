# Pravdabox namespace
P = window.P || {}

P.ws_endpoint = 'ws://' + location.host + '/ws-bin'

P.max_lines = 100
P.max_links = 10 # maximum of links on the map
P.howmanycolors = 7

P.dns = ->
    ws = new WebSocket P.ws_endpoint + '/dns'

    c = 0
    ws.onmessage = (event) ->
        line = P.colorize event.data
        if P.dns_add line
            $('.widget-dns .filterwindow').html ''
            c = 0
            for address in P.dns_bin
                $('<div class="l l-' + c + '">' + address + '</div>').appendTo '.widget-dns .filterwindow'
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

            # Plot it on the map
            ip = event.data.split('\t')[1]
            P.map.ip2location ip, ->
                P.map.update()

            # plot it in connection window
            $('.widget-connections .filterwindow').html ''
            c = 0
            for connection in P.connections_bin
                $('<div class="l l-' + c + '">' + connection + '</div>').appendTo '.widget-connections .filterwindow'
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
            $('.widget-forms .filterwindow').html ''
            c = 0
            for form in P.forms_bin
                $('<div class="l l-' + c + '">' + form + '</div>').appendTo '.widget-forms .filterwindow'
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
            $('.widget-cookies .filterwindow').html ''
            c = 0
            for cookie in P.cookies_bin
                $('<div class="l l-' + c + '">' + cookie + '</div>').appendTo '.widget-cookies .filterwindow'
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
        $('<a href="/image/' + event.data + '" target="_blank"><img class="i i-' + c + '" src="/image/' + event.data + '"></a>').prependTo '.widget-images .filterwindow'
        if $('.widget-images .i').length > P.max_lines
            $('.widget-images .i-' + (c - P.max_lines)).remove()
        P.scroller 'images'
        c++

P.passwords = ->
    ws = new WebSocket P.ws_endpoint + '/passwords'

    ws.onmessage = (event) ->
        line = P.colorize event.data
        if P.passwords_add line
            $('.widget-passwords .filterwindow').html ''
            c = 0
            for password in P.passwords_bin
                $('<div class="l l-' + c + '">' + password + '</div>').appendTo '.widget-passwords .filterwindow'
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
            $('.widget-urls .filterwindow').html ''
            c = 0
            for url in P.urls_bin
                $('<div class="l l-' + c + '">' + url + '</div>').appendTo '.widget-urls .filterwindow'
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

            appended = false
            setInterval ->
                try
                    $.ajax
                        url: 'http://' + location.host + '/firmwareupgrade/mapimport_done'
                        success: (data) ->
                            if data == 'true'
                                location.href = 'http://' + location.host
                            else
                                if not appended
                                    $('<div class="l">Importing geolocation data, please wait. This can take some minutes. Will reload automatically when done.</div>').appendTo '.firmwareupgrade'
                                    appended = true
            , 5000

        $('#start_firmwareupgrade').remove()
        return false

P.scroller = (filter) ->
    $('.widget-' + filter + ' .filterwindow').animate
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

P.widgets =
    positions: {}
    visibility: {}

    init: ->

        # load positions
        P.widgets.loadpositions()

        # load visibilities
        P.widgets.loadvisibilities()

        # make them toggleable
        P.widgets.init_toggle()

        # make it draggable
        $('.widget').draggable
            handle: '.head'
            stack: '.widget'
            stop: (ev, ui) ->
                P.widgets.savepositions()

        # make it resizable
        for w in 'dns,connections,cookies,forms,passwords,urls,images'.split ','
            $(".widget-#{w}").resizable
                alsoResize: ".widget-#{w} .filterwindow"
                stop: (ev, ui) ->
                    $this = $(this)
                    width = $this.width() - 22
                    $this.find('.filterwindow').css('width', width + 'px')
                    P.widgets.savepositions()

    init_toggle: ->
        P.widgets.setstate()

        $('.widgettoggle').on 'click', ->
            $w = $(this)
            w = $w.data('name')
            if P.widgets.visibility[w] == 0
                P.widgets.visibility[w] = 1
            else
                P.widgets.visibility[w] = 0

            P.widgets.savepositions()
            P.widgets.setstate()

            # no href-action on click
            return false

    savepositions: ->
        for w in 'dns,connections,cookies,forms,passwords,urls,images'.split ','
            $w = $(".widget-#{w}")
            P.widgets.positions[w] = [
                $w.position().top
                $w.position().left
                $w.width()
                $w.height() - 42
                P.widgets.visibility[w]
            ]

        Cookies.set 'pb_widgets', JSON.stringify(P.widgets.positions),
            expires: 360

    loadpositions: ->
        try
            P.widgets.positions = JSON.parse(Cookies.get 'pb_widgets')
            for w in 'dns,connections,cookies,forms,passwords,urls,images'.split ','
                $w = $(".widget-#{w}")
                $w.css 'top', P.widgets.positions[w][0]
                $w.css 'left', P.widgets.positions[w][1]
                $w.css 'width', P.widgets.positions[w][2]
                $w.css 'height', P.widgets.positions[w][3] + 42
                $w.find('.filterwindow').css 'height', P.widgets.positions[w][3]

    loadvisibilities: ->
        try
            P.widgets.positions = JSON.parse(Cookies.get 'pb_widgets')
            for w in 'dns,connections,cookies,forms,passwords,urls,images'.split ','
                P.widgets.visibility[w] = P.widgets.positions[w][4]
        catch
            for w in 'dns,connections,cookies,forms,passwords,urls,images'.split ','
                P.widgets.visibility[w] = 1

    setstate: ->
        # determine whether or not to display the widget
        for w in 'dns,connections,cookies,forms,passwords,urls,images'.split ','
            $menu = $(".widgettoggle[data-name=#{w}]")
            menutext = $menu.text().replace /✓/g, ''
            if P.widgets.visibility[w] == 1
                $(".widget-#{w}").css 'visibility', 'visible'
                menutext = '✓' + menutext
            else
                $(".widget-#{w}").css 'visibility', 'hidden'
            $menu.text menutext

P.map =
    markers: []
    ip_coords: {}
    homeip: null

    options:
        map:
            name: 'world_countries_miller'
            defaultArea:
                attrs:
                    fill: '#08304b'
                    stroke: '#08304b'
                    'stroke-width': 0.3
                attrsHover:
                    animDuration: 0
                    fill: '#08304b'
            defaultPlot:
                attrs:
                    fill: '#ff0'
                    stroke: '#000'
                    r: 1
                attrsHover:
                    'stroke-width': 0
                    r: 1
                text:
                    attrs:
                        fill: '#fff'
                        'font-size': 5
                    margin: 1
            defaultLink:
                attrs:
                    stroke: '#0f0'
                    'stroke-width': 0.3
                factor: -0.1
            zoom:
                enabled: true
                init:
                    latitude: 50
                    longitude: 0
                    level: 0
                animDuration: 0
                step: 1
                maxLevel: 10

    init: ->
        P.map.homeip = $('.map').data('homeip')
        P.map.ip2location P.map.homeip, ->
            P.map.render()

    render: ->
        P.map.scale_to_window()
        $('.mapcontainer').mapael P.map.options

    update: ->
        P.map.scale_to_window()

        plots = {}
        links = {}

        if P.map.markers.length > P.max_links + 1
            P.map.markers.splice 1, 1

        for m in P.map.markers
            # plot
            plots[m.ip] =
                latitude: m.lat
                longitude: m.lng
                tooltip:
                    content: "#{m.ip}<br /><br />#{m.city_name}<br />#{m.region_name}<br />#{m.country_name}"
            # link
            links[ "#{P.map.homeip}-#{m.ip}" ] =
                between:
                    [P.map.homeip, m.ip]

        $('.mapcontainer').trigger 'update', [
            newPlots: plots
            newLinks: links
            deletePlotKeys: 'all'
            deleteLinkKeys: 'all'
            animDuration: 0
        ]

    ip2location: (ip, done) ->
        if not P.map.ip_coords[ip]
            $.get 'ip2location?ip=' + ip, (data) ->
                P.map.ip_coords[ip] = data
                j = $.parseJSON(data)
                if j.lat != 0 and j.lng != 0
                    P.map.markers.push j
                done(data)
        else
            done(P.map.ip_coords[ip])

    scale_to_window: ->
        $('.mapcontainer, .mapcontainer .map').css
            width: $(window).width()
            height: $(window).height() - 20

$ ->
    P.dns()
    P.connections()
    P.forms()
    P.cookies()
    P.images()
    P.passwords()
    P.urls()
    P.firmwareupgrade()
    P.widgets.init()
    P.map.init()

