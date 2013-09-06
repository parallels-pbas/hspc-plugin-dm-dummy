MAKEDIRS	= lib i18n help
PREFIX		= /

MKDIR		= mkdir -p
PERL		= /usr/bin/perl

all:
	@for i in $(MAKEDIRS); do \
		make -C $$i PREFIX=$(PREFIX) || exit 1 ; \
	done ;
	make -C upgrade PREFIX=$(PREFIX)/usr

install:
	@for i in $(MAKEDIRS); do \
		make -C $$i PREFIX=$(PREFIX) install || exit 1 ; \
	done ;
	make -C upgrade PREFIX=$(PREFIX)/usr $@

clean:
	@for i in $(MAKEDIRS); do \
		make -C $$i PREFIX=$(PREFIX) clean || exit 1 ; \
	done ;
 