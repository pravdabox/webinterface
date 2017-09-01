# Pravdabox namespace
P = window.P || {}

P.dns = ->
    ws = new WebSocket 'ws://192.168.42.1:8081/'
    maxlen = 10

    c = 0
    ws.onmessage = (event) ->
        $('.filter-dns .line:last').append '<div class="l l-' + c + '">' + event.data + '</div>'
        if $('.filter-dns .l').length > maxlen
            $('.filter-dns .l-' + (c - maxlen)).remove()
        c++

$ ->
    P.dns()

