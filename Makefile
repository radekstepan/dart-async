DART_SDK = /home/radek/bin/darteditor-linux-x64/dart-sdk/bin

install:
	$(DART_SDK)/pub install

test:
	$(DART_SDK)/dart --checked test/async_test.dart

.PHONY: test