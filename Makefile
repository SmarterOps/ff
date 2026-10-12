PREFIX ?= /usr/local

install:
	@install -d $(DESTDIR)$(PREFIX)/bin
	@install -m 755 ff $(DESTDIR)$(PREFIX)/bin/ff
	@echo "ff installed to $(DESTDIR)$(PREFIX)/bin/ff"

uninstall:
	@rm -f $(DESTDIR)$(PREFIX)/bin/ff
	@echo "ff removed from $(DESTDIR)$(PREFIX)/bin/ff"