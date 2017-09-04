# Pravdabox namespace
P = window.P || {}

P.dns = ->
    ws = new WebSocket 'ws://192.168.42.1/ws-bin/dns'
    #ws = new WebSocket 'ws://localhost:8080/ws-bin/dns'
    maxlen = 10

    c = 0
    ws.onmessage = (event) ->
        #$('.filter-dns .l:last').append '<div class="l l-' + c + '">' + event.data + '</div>'
        $('<div class="l l-' + c + '">' + event.data + '</div>').appendTo '.filter-dns'
        if $('.filter-dns .l').length > maxlen
            $('.filter-dns .l-' + (c - maxlen)).remove()
        c++

P.images = ->
    ws = new WebSocket 'ws://192.168.42.1/ws-bin/images'
    #ws = new WebSocket 'ws://localhost:8080/ws-bin/images'
    maxlen = 30

    c = 0
    ws.onmessage = (event) ->
        $('<a href="/image/' + event.data + '" target="_blank"><img class="i i-' + c + '" src="/image/' + event.data + '"></a>').prependTo '.filter-images'
        if $('.filter-images .i').length > maxlen
            $('.filter-images .i-' + (c - maxlen)).remove()
        c++

$ ->
    P.dns()
    P.images()

