PREFIX			= /
HSPC_TEMPLATE	= $(PREFIX)/var/opt/hspc-root/template
PLUGIN_PATH		= $(HSPC_TEMPLATE)/HSPC/Plugin/DM/Dummy/help

MKDIR			= mkdir -p

all:

install:
	mkdir -p $(PLUGIN_PATH)
	for i in `find . -type f | grep -v svn`; do \
		install -Dm644 $$i $(PLUGIN_PATH)/$$i || exit $?; \
	done

clean:
