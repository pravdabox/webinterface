all:
	clear
	go build
	./webinterface

pack-assets:
	go-bindata-assetfs -debug static/... templates/...

pack-assets-production:
	go-bindata-assetfs static/... templates/...

.PHONY: all
