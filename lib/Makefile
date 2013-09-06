PREFIX		= /

MKDIR		= mkdir -p

all: Makefile.perl
	make -f Makefile.perl PREFIX=$(PREFIX)/usr

Makefile.perl: Makefile.PL
	perl Makefile.PL PREFIX=$(PREFIX)

install:
	make -f Makefile.perl PREFIX=$(PREFIX)/usr install

	# clean up
	find $(PREFIX)/usr -type f -name perllocal.pod -exec rm -f \{\} \;
	find $(PREFIX)/usr -type f -name .packlist -exec rm -f \{\} \;
	rm -rf `find $(PREFIX) -type d -name man`

clean:
	make -f Makefile.perl clean
