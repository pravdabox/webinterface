all: pack-assets-production
	clear
	go build
	./webinterface

pack-assets:
	go-bindata-assetfs -debug static/... templates/...

pack-assets-production:
	coffee -b -c static/js/90-pravdabox.coffee
	cat static/js/*.js > static/combined.js
	cat static/css/*.css > static/combined.css
	go-bindata-assetfs static/... templates/...

.PHONY: all
