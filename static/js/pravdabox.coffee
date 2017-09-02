# Pravdabox namespace
P = window.P || {}

P.dns = ->
    ws = new WebSocket 'ws://192.168.42.1/ws-bin/dns'
    #ws = new WebSocket 'ws://localhost:8088/ws-bin/dns'
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
    #ws = new WebSocket 'ws://localhost:8088/ws-bin/images'

    ws.onmessage = (event) ->
        $('.filter-images .display').html event.data

$ ->
    P.dns()
    P.images()

