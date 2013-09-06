FACTORY=plugin-dm-dummy
PREFIX=/usr
SHARE=$(PREFIX)/share/hspc-upgrade/upgrade/$(FACTORY)

all::

install::
	mkdir -p $(SHARE)
	for i in `find . -type f | grep -v svn`; do \
		install -Dm644 $$i $(SHARE)/$$i || exit $?; \
	done

clean::
