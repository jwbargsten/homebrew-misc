
inject-m1-arm-bottles:
	curl -L https://bargsten.org/misc-m1-arm-bottles.tar.gz -o misc-m1-arm-bottles.tar.gz 
	tar -xvzf misc-m1-arm-bottles.tar.gz

packm1:
	tar -cvzf misc-m1-arm-bottles.tar.gz *.arm64_ventura.bottle.*

bottlem1:
	brew bottle --json --root-url=https://ghcr.io/v2/jwbargsten/homebrew-misc \
		jwbargsten/misc/go-mssql-load \
		jwbargsten/misc/defbro
cleanm1:
	rm -f *.arm64_ventura.bottle.*
