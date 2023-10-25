.PHONY: dist bottles

TAP=jwbargsten/misc
FORMULAS=$(patsubst Formula/%.rb, %, $(wildcard Formula/*.rb))
BOTTLES=$(wildcard *.bottle.json)
ARTIFACTS=$(BOTTLES:%.bottle.json=dist/%.artifact.tar.gz)

inject-arm64-bottles:
	./script/download-arm64-bottles.pl

bottles:
	brew bottle --json \
		--root-url=https://ghcr.io/v2/jwbargsten/homebrew-misc \
		$(FORMULAS:%=$(TAP)/%)

clean:
	rm -f *.arm64_ventura.bottle.*
	rm -rf dist/

dist: bottles $(ARTIFACTS)

dist/%.artifact.tar.gz: %.bottle.json
	mkdir -p dist
	./script/pack-artifact.pl $< $@

build:
	brew uninstall jwbargsten/misc/go-mssql-load
	HOMEBREW_NO_INSTALL_FROM_API=1 brew install --verbose --build-bottle jwbargsten/misc/go-mssql-load
