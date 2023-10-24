
inject-m1-arm-bottles:
	curl -L https://bargsten.org/misc-m1-arm-bottles.tar.gz -o misc-m1-arm-bottles.tar.gz 
	tar -xvzf misc-m1-arm-bottles.tar.gz
pack-m1-arm-bottles:
	tar -cvzf misc-m1-arm-bottles.tar.gz *.arm64_ventura.bottle.*
