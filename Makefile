all: pack-assets
	clear
	go build
	./webinterface -d

pack-assets:
	coffee -b -c static/js/90-pravdabox.coffee
	cat static/js/*.js > static/combined.js
	cat static/css/*.css > static/combined.css
	go-bindata-assetfs static/... templates/...

.PHONY: all
