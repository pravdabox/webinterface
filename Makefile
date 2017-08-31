all:
	clear
	go run webinterface.go

pack-assets:
	go-bindata -debug static/...

pack-assets-production:
	go-bindata static/...

.PHONY: all
