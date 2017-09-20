# Pravdabox namespace
P = window.P || {}

P.ws_endpoint = 'ws://192.168.42.1/ws-bin'
#P.ws_endpoint = 'ws://localhost:8080/ws-bin'

P.dns = ->
    ws = new WebSocket P.ws_endpoint + '/dns'
    maxlen = 10

    c = 0
    ws.onmessage = (event) ->
        #$('.filter-dns .l:last').append '<div class="l l-' + c + '">' + event.data + '</div>'
        $('<div class="l l-' + c + '">' + event.data + '</div>').prependTo '.filter-dns'
        if $('.filter-dns .l').length > maxlen
            $('.filter-dns .l-' + (c - maxlen)).remove()
        c++

P.connections = ->
    ws = new WebSocket P.ws_endpoint + '/connections'
    maxlen = 10

    c = 0
    ws.onmessage = (event) ->
        #$('.filter-connections .l:last').append '<div class="l l-' + c + '">' + event.data + '</div>'
        $('<div class="l l-' + c + '">' + event.data + '</div>').prependTo '.filter-connections'
        if $('.filter-connections .l').length > maxlen
            $('.filter-connections .l-' + (c - maxlen)).remove()
        c++

P.http = ->
    ws = new WebSocket P.ws_endpoint + '/http'
    maxlen = 10

    c = 0
    ws.onmessage = (event) ->
        #$('.filter-http .l:last').append '<div class="l l-' + c + '">' + event.data + '</div>'
        $('<div class="l l-' + c + '">' + event.data + '</div>').prependTo '.filter-http'
        if $('.filter-http .l').length > maxlen
            $('.filter-http .l-' + (c - maxlen)).remove()
        c++

P.cookies = ->
    ws = new WebSocket P.ws_endpoint + '/cookies'
    maxlen = 10

    c = 0
    ws.onmessage = (event) ->
        #$('.filter-cookies .l:last').append '<div class="l l-' + c + '">' + event.data + '</div>'
        $('<div class="l l-' + c + '">' + event.data + '</div>').prependTo '.filter-cookies'
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
