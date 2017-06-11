
SOURCES_ROOT=./src
BUILD_ROOT=./build
PREFIX_ROOT=./lib

ABSOLUTE_SOURCES_ROOT := $(realpath $(SOURCES_ROOT))
ABSOLUTE_BUILD_ROOT := $(realpath $(BUILD_ROOT))
ABSOLUTE_PREFIX_ROOT := $(realpath $(PREFIX_ROOT))

ifeq "$(MAKE_MODE)" ""
MAKE_MODE := release
endif

ifeq "$(MAKE_MODE)" "debug"
CMAKE_BUILD_TYPE := Debug
else
CMAKE_BUILD_TYPE := Release
endif

# Save the current directory
THIS_DIR := $(shell pwd)

define GIT_DOWNLOAD =
$(1)_VERSION := $(2)
$(1)_VERSION_FILE := $(ABSOLUTE_PREFIX_ROOT)/built_$(1)
$(1)_SOURCE := $(3)
$(1)_FILE := $(ABSOLUTE_SOURCES_ROOT)/$$(notdir $$($(1)_SOURCE))
$(1): $$($(1)_VERSION_FILE)

$$($(1)_FILE)/HEAD :
	mkdir -p $(ABSOLUTE_SOURCES_ROOT) && \
	echo Downloading $$($(1)_FILE)... && \
	git clone -q --bare $$($(1)_SOURCE) `cygpath -w $$($(1)_FILE)`
endef

$(eval $(call GIT_DOWNLOAD,zlib,v1.2.8,git://github.com/madler/zlib.git))

# Number or processors
ifeq "$(OS)" "Darwin"
JOPT := -j$(shell sysctl -n machdep.cpu.thread_count)
endif
ifeq "$(OS)" "linux"
JOPT := -j$(shell cat /sys/devices/system/cpu/cpu*/topology/thread_siblings | wc -l)
endif
ifeq "$(OS)" "WINDOWS"
JOPT := -j$(shell cat /proc/cpuinfo | grep processor | wc -l)
endif

# libz
$(zlib_VERSION_FILE) : $(zlib_FILE)/HEAD
	@echo Building external zlib $(zlib_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf zlib && \
	git clone -q --no-checkout `cygpath -w $(ABSOLUTE_SOURCES_ROOT)/zlib.git` zlib && \
	cd zlib && \
	git checkout -q $(zlib_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	nmake -f win32/Makefile.msc "CFLAGS=/nologo $(CL_MODE_FLAGS) /GR /EHsc" zlib.lib > $(ABSOLUTE_PREFIX_ROOT)/log_zlib.txt 2>&1 && \
	cd $(ABSOLUTE_PREFIX_ROOT) && mkdir -p zlib/include && mkdir -p zlib/lib && \
	cp $(ABSOLUTE_BUILD_ROOT)/zlib/zlib.lib zlib/lib/z.lib && \
	cp $(ABSOLUTE_BUILD_ROOT)/zlib/zlib.h zlib/include/ && \
	cp $(ABSOLUTE_BUILD_ROOT)/zlib/zconf.h zlib/include/ && \
	rm -rf $(ABSOLUTE_BUILD_ROOT)/zlib && \
	cd $(THIS_DIR) && \
	echo $(zlib_VERSION) > $@

