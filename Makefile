all:
	clear
	go build
	./webinterface

pack-assets:
	go-bindata-assetfs -debug static/...

pack-assets-production:
	go-bindata-assetfs static/...

.PHONY: all
