PACKAGE = pacman-mirrorlist
ORG = amylum

VERSION = $$(cat version)
RELEASE_DIR = /tmp/$(PACKAGE)-release
RELEASE_FILE = /tmp/$(PACKAGE).tar.gz

.PHONY : default manual container build version push local

default: container

manual:
	./meta/launch /bin/bash || true

container:
	./meta/launch

build:
	mkdir -p $(RELEASE_DIR)/etc/pacman.d
	curl -so $(RELEASE_DIR)/etc/pacman.d/mirrorlist https://www.archlinux.org/mirrorlist/all/
	cd $(RELEASE_DIR) && tar -czvf $(RELEASE_FILE) *

version:
	awk '/^## Generated on/ {gsub("-", ""); print $$NF}' $(RELEASE_DIR)/etc/pacman.d/mirrorlist > version

push: version
	git commit -am "$(VERSION)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "$(VERSION)"
	git push --tags origin master
	@sleep 3
	targit -a .github -c -f $(ORG)/$(PACKAGE) $(VERSION) $(RELEASE_FILE)
	@sha512sum $(RELEASE_FILE) | cut -d' ' -f1

local: build push

