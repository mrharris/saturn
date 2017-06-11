
SOURCES_ROOT=./src
BUILD_ROOT=./build
PREFIX_ROOT=./lib

ABSOLUTE_SOURCES_ROOT := $(realpath $(SOURCES_ROOT))
ABSOLUTE_BUILD_ROOT := $(realpath $(BUILD_ROOT))
ABSOLUTE_PREFIX_ROOT := $(realpath $(PREFIX_ROOT))

ZLIB_VERSION := v1.2.8

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

# Version files that should indicate that the build is successfull
ZLIB_VERSION_FILE := $(ABSOLUTE_PREFIX_ROOT)/built_zlib

ZLIB_SOURCE := git://github.com/madler/zlib.git

ZLIB_FILE := $(ABSOLUTE_SOURCES_ROOT)/$(notdir $(ZLIB_SOURCE))

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

zlib: $(ZLIB_VERSION_FILE)

download : $(BOOST_FILE) $(CMAKE_FILE) $(ILMBASE_FILE) $(JPEG_FILE)/HEAD $(JSONCPP_FILE)/HEAD $(OCIO_FILE)/HEAD $(OIIO_FILE)/HEAD $(OPENEXR_FILE) $(PNG_FILE)/HEAD $(PYSTRING_FILE)/HEAD $(PYTHON_FILE) $(TIFF_FILE) $(ZLIB_FILE)/HEAD

$(ZLIB_FILE)/HEAD :
	@mkdir -p $(ABSOLUTE_SOURCES_ROOT) && \
	echo Downloading $(ZLIB_FILE)... && \
	git clone -q --bare $(ZLIB_SOURCE) $(ZLIB_FILE)

# libz
$(ZLIB_VERSION_FILE) : $(ZLIB_FILE)/HEAD
	@echo Building external zlib $ZLIB_VERSION && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf zlib && \
	git clone -q --no-checkout `cygpath -w $(ABSOLUTE_SOURCES_ROOT)/zlib.git` zlib && \
	cd zlib && \
	git checkout -q $(ZLIB_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	nmake -f win32/Makefile.msc "CFLAGS=/nologo $(CL_MODE_FLAGS) /GR /EHsc" zlib.lib > $(ABSOLUTE_EXTERNAL_BUILD_ROOT)/log_zlib.txt 2>&1 && \
	cd $(ABSOLUTE_PREFIX_ROOT) && mkdir -p zlib/include && mkdir -p zlib/lib && \
	cp $(ABSOLUTE_BUILD_ROOT)/zlib/zlib.lib zlib/lib/z.lib && \
	cp $(ABSOLUTE_BUILD_ROOT)/zlib/zlib.h zlib/include/ && \
	cp $(ABSOLUTE_BUILD_ROOT)/zlib/zconf.h zlib/include/ && \
	rm -rf $(ABSOLUTE_BUILD_ROOT)/zlib.src && \
	cd $(THIS_DIR) && \
	echo $(ZLIB_VERSION) > $@

