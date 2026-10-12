PREFIX ?= /usr/local

.PHONY: install uninstall test

install:
	@install -d $(DESTDIR)$(PREFIX)/bin
	@install -m 755 ff $(DESTDIR)$(PREFIX)/bin/ff
	@echo "ff installed to $(DESTDIR)$(PREFIX)/bin/ff"

test:
	@bash -n ff install.sh tests/test_ff.sh tests/test_install.sh
	@bash tests/test_ff.sh
	@bash tests/test_install.sh

uninstall:
	@rm -f $(DESTDIR)$(PREFIX)/bin/ff
	@echo "ff removed from $(DESTDIR)$(PREFIX)/bin/ff"