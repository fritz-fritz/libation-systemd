PKG := libation-systemd
DIST := dist
NFPM := $(shell go env GOPATH)/bin/nfpm pkg -f packaging/nfpm.yaml
TAG := $(shell git for-each-ref --sort=-v:refname --count=1 --format="%(refname:short)" refs/tags 2>/dev/null || echo "v0.0.0")
TAG_NO_V := $(patsubst v%,%,$(TAG))
BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
TIMESTAMP := $(shell date -u +"%Y%m%dT%H%M%SZ")
TAG_VERSION := $(TAG_NO_V)-$(BRANCH)+$(TIMESTAMP)


DEB := $(DIST)/$(PKG)_$(TAG_NO_V)\~$(BRANCH)+$(TIMESTAMP)_*.deb
RPM := $(DIST)/$(PKG)_$(TAG_NO_V)\~$(BRANCH)+$(TIMESTAMP)-*.rpm

.PHONY: all package deb rpm clean install uninstall

all: package

package: deb rpm

deb:
	mkdir -p $(DIST)
	TAG_VERSION=$(TAG_VERSION) $(NFPM) -p deb -t $(DIST)

rpm:
	mkdir -p $(DIST)
	TAG_VERSION=$(TAG_VERSION) $(NFPM) -p rpm -t $(DIST)

install: package
	@echo "Installing $(PKG)..."
	@if command -v apt >/dev/null; then \
		sudo apt install -y ./$(DEB) ; \
	elif command -v rpm >/dev/null; then \
		sudo rpm -Uvh $(RPM); \
	else \
		echo "No package manager found!"; exit 1; \
	fi
	@echo "Installation complete."

uninstall:
	@echo "Uninstalling $(PKG)…"
	@if command -v apt >/dev/null; then \
	  if dpkg-query -W -f='${Status}' $(PKG) 2>/dev/null | grep -q "install ok installed"; then \
		sudo apt purge --autoremove -y $(PKG); \
	  else \
		echo "$(PKG) is not installed via apt, skipping."; \
	  fi; \
	elif command -v rpm >/dev/null; then \
	  if rpm -q $(PKG) >/dev/null 2>&1; then \
		sudo rpm -e $(PKG); \
	  else \
		echo "$(PKG) is not installed via rpm, skipping."; \
	  fi; \
	else \
	  echo "No supported package manager found, skipping package removal."; \
	fi
	@echo "Removing user configuration files…"
	@rm -rf $(HOME)/.config/systemd/user/libation* \
			 $(HOME)/.config/systemd/user/app-libation.slice || true
	@echo "Uninstall complete."

clean:
	rm -rf $(DIST)