
SOURCES_ROOT=./src
BUILD_ROOT=./build
PREFIX_ROOT=./lib

ABSOLUTE_SOURCES_ROOT := $(abspath $(SOURCES_ROOT))
ABSOLUTE_BUILD_ROOT := $(abspath $(BUILD_ROOT))
ABSOLUTE_PREFIX_ROOT := $(abspath $(PREFIX_ROOT))
WINDOWS_SOURCES_ROOT := $(shell cygpath -w $(ABSOLUTE_SOURCES_ROOT))
WINDOWS_BUILD_ROOT := $(shell cygpath -w $(ABSOLUTE_BUILD_ROOT))
WINDOWS_PREFIX_ROOT := $(subst \,/,$(shell cygpath -w $(ABSOLUTE_PREFIX_ROOT)))

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
TOP_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
WINDOWS_THIS_DIR := $(shell cygpath -w $(THIS_DIR))

define GIT_DOWNLOAD =
$(1)_VERSION := $(2)
$(1)_VERSION_FILE := $(ABSOLUTE_PREFIX_ROOT)/built_$(1)
$(1)_SOURCE := $(3)
$(1)_FILE := $(ABSOLUTE_SOURCES_ROOT)/$$(notdir $$($(1)_SOURCE))
$(1): $$($(1)_VERSION_FILE)

$$($(1)_FILE)/HEAD :
	@mkdir -p $(ABSOLUTE_SOURCES_ROOT) && \
	echo Downloading $$($(1)_FILE)... && \
	git clone -q --bare $$($(1)_SOURCE) `cygpath -w $$($(1)_FILE)`

$(1)-archive: $(1)-$$($(1)_VERSION).tar.xz
$(1)-$$($(1)_VERSION).tar.xz: $$($(1)_VERSION_FILE)
	@echo Archiving $$@ && \
	tar cfJ $$@ -C $(ABSOLUTE_PREFIX_ROOT) $(1)
endef

define CURL_DOWNLOAD =
$(1)_VERSION := $(2)
$(1)_VERSION_FILE := $(ABSOLUTE_PREFIX_ROOT)/built_$(1)
$(1)_SOURCE := $(3)
$(1)_FILE := $(ABSOLUTE_SOURCES_ROOT)/$$(notdir $$($(1)_SOURCE))
$(1): $$($(1)_VERSION_FILE)

$$($(1)_FILE) :
	@mkdir -p $(ABSOLUTE_SOURCES_ROOT) && \
	echo Downloading $$($(1)_FILE)... && \
	curl --tlsv1.2 -s -o $$@ -L $$($(1)_SOURCE)

$(1)-archive: $(1)-$$($(1)_VERSION).tar.xz
$(1)-$$($(1)_VERSION).tar.xz: $$($(1)_VERSION_FILE)
	@echo Archiving $$@ && \
	tar cfJ $$@ -C $(ABSOLUTE_PREFIX_ROOT) $(1)
endef

$(eval $(call CURL_DOWNLOAD,boost,1_61_0,http://sourceforge.net/projects/boost/files/boost/$$(subst _,.,$$(boost_VERSION))/boost_$$(boost_VERSION).tar.gz))
$(eval $(call CURL_DOWNLOAD,cmake,3.9.1,https://cmake.org/files/v$$(word 1,$$(subst ., ,$$(cmake_VERSION))).$$(word 2,$$(subst ., ,$$(cmake_VERSION)))/cmake-$$(cmake_VERSION)-win64-x64.zip))
$(eval $(call CURL_DOWNLOAD,freetype,2.8,http://download.savannah.gnu.org/releases/freetype/freetype-$$(freetype_VERSION).tar.gz))
$(eval $(call CURL_DOWNLOAD,glew,2.0.0,https://sourceforge.net/projects/glew/files/glew/$$(glew_VERSION)/glew-$$(glew_VERSION).tgz))
$(eval $(call CURL_DOWNLOAD,glut,3.0.0,https://sourceforge.net/projects/freeglut/files/freeglut/$$(glut_VERSION)/freeglut-$$(glut_VERSION).tar.gz))
$(eval $(call CURL_DOWNLOAD,hdf5,1.8.10,https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-$$(word 1,$$(subst ., ,$$(hdf5_VERSION))).$$(word 2,$$(subst ., ,$$(hdf5_VERSION)))/hdf5-$$(hdf5_VERSION)/src/hdf5-$$(hdf5_VERSION).tar.gz))
$(eval $(call CURL_DOWNLOAD,ilmbase,2.2.0,http://download.savannah.nongnu.org/releases/openexr/ilmbase-$$(ilmbase_VERSION).tar.gz))
$(eval $(call CURL_DOWNLOAD,openexr,2.2.0,http://download.savannah.nongnu.org/releases/openexr/openexr-$$(openexr_VERSION).tar.gz))
$(eval $(call CURL_DOWNLOAD,perl,5.26.1,http://www.cpan.org/src/5.0/perl-$$(perl_VERSION).tar.gz))
$(eval $(call CURL_DOWNLOAD,tbb,2017_20161128oss,https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb$$(tbb_VERSION)_src.tgz))
$(eval $(call CURL_DOWNLOAD,tiff,3.8.2,http://dl.maptools.org/dl/libtiff/tiff-$$(tiff_VERSION).tar.gz))
$(eval $(call GIT_DOWNLOAD,alembic,1.7.1,git://github.com/alembic/alembic.git))
$(eval $(call GIT_DOWNLOAD,embree,v2.17.0,git://github.com/embree/embree.git))
$(eval $(call GIT_DOWNLOAD,glfw,3.2.1,git://github.com/glfw/glfw.git))
$(eval $(call GIT_DOWNLOAD,jom,v1.1.2,git://github.com/qt-labs/jom.git))
$(eval $(call GIT_DOWNLOAD,jpeg,1.5.1,git://github.com/libjpeg-turbo/libjpeg-turbo.git))
$(eval $(call GIT_DOWNLOAD,jsoncpp,1.8.0,git://github.com/open-source-parsers/jsoncpp.git))
$(eval $(call GIT_DOWNLOAD,oiio,Release-1.8.5,git://github.com/OpenImageIO/oiio.git))
$(eval $(call GIT_DOWNLOAD,opensubd,v3_2_0,git://github.com/PixarAnimationStudios/OpenSubdiv.git))
$(eval $(call GIT_DOWNLOAD,png,2b667e4,git://git.code.sf.net/p/libpng/code))
$(eval $(call GIT_DOWNLOAD,ptex,v2.1.28,git://github.com/wdas/ptex.git))
$(eval $(call GIT_DOWNLOAD,qt5base,v5.9.2,git://github.com/qt/qtbase.git))
$(eval $(call GIT_DOWNLOAD,usd,v0.8.1,git://github.com/PixarAnimationStudios/USD))
$(eval $(call GIT_DOWNLOAD,zlib,v1.2.8,git://github.com/madler/zlib.git))

# Number or processors
JOB_COUNT := $(shell cat /proc/cpuinfo | grep processor | wc -l)

CC := $(shell where cl)
CXX := $(shell where cl)
CMAKE := env -u MAKE -u MAKEFLAGS $(ABSOLUTE_PREFIX_ROOT)/cmake/bin/cmake

BOOST_LINK := static
ifeq "$(BOOST_LINK)" "shared"
USE_STATIC_BOOST := OFF
BUILD_USD_MAYA_PLUGIN := ON
else
USE_STATIC_BOOST := ON
BUILD_USD_MAYA_PLUGIN := OFF
endif

DEFINES = /DBOOST_ALL_NO_LIB /DPTEX_STATIC

ifeq "$(BOOST_LINK)" "shared"
DEFINES += /DBOOST_ALL_DYN_LINK
else
DEFINES += /DBOOST_ALL_STATIC_LINK
DEFINES += /DBOOST_PYTHON_STATIC_LIB
endif

COMMON_CMAKE_FLAGS :=\
	-G "NMake Makefiles JOM" \
	-DCMAKE_BUILD_TYPE:STRING=$(CMAKE_BUILD_TYPE) \
	-DCMAKE_CXX_FLAGS_DEBUG="/MTd $(DEFINES)" \
	-DCMAKE_CXX_FLAGS_RELEASE="/MT $(DEFINES)" \
	-DCMAKE_C_FLAGS_DEBUG="/MTd $(DEFINES)" \
	-DCMAKE_C_FLAGS_RELEASE="/MT $(DEFINES)" \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON

all: usd-$(usd_VERSION)-$(BOOST_LINK).tar.xz
.PHONY : all
.DEFAULT_GOAL := all

PYTHON_BIN := C:/Python27/python.exe
PYTHON_VERSION_SHORT := 2.7
PYTHON_ROOT := $(subst \,,$(dir $(PYTHON_BIN)))
PYTHON_BIN := $(subst \,,$(PYTHON_BIN))
PYTHON_INCLUDE := $(PYTHON_ROOT)include
PYTHON_LIBS := $(PYTHON_ROOT)libs

ifeq "$(BOOST_VERSION)" "1_55_0"
BOOST_USERCONFIG := tools/build/v2/user-config.jam
else
BOOST_USERCONFIG := tools/build/src/user-config.jam
endif
$(boost_VERSION_FILE) : $(boost_FILE)
	@echo Building boost $(boost_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(BUILD_ROOT) && \
	rm -rf boost_$(boost_VERSION) && \
	tar -xf $(ABSOLUTE_SOURCES_ROOT)/boost_$(boost_VERSION).tar.gz && \
	cd boost_$(boost_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	echo 'using msvc : 14.1 : "$(CXX)" ;' > $(BOOST_USERCONFIG) && \
	echo 'using python : $(PYTHON_VERSION_SHORT) : "$(PYTHON_BIN)" : "$(PYTHON_INCLUDE)" : "$(PYTHON_LIBS)" ;' && \
	echo 'using python : $(PYTHON_VERSION_SHORT) : "$(PYTHON_BIN)" : "$(PYTHON_INCLUDE)" : "$(PYTHON_LIBS)" ;' >> $(BOOST_USERCONFIG) && \
	( printf '/handle-static-runtime/\n/EXIT/d\nw\nq' | ed -s Jamroot ) && \
	cmd /C bootstrap.bat msvc > $(ABSOLUTE_PREFIX_ROOT)/log_boost.txt 2>&1 && \
	./b2 \
		--layout=system \
		--prefix=`cygpath -w $(ABSOLUTE_PREFIX_ROOT)/boost` \
		-j $(JOB_COUNT) \
		link=$(BOOST_LINK) \
		threading=multi \
		runtime-link=static \
		address-model=64 \
		toolset=msvc-14.1 \
		$(MAKE_MODE) \
		stage \
		install >> $(ABSOLUTE_PREFIX_ROOT)/log_boost.txt 2>&1 && \
	cd .. && \
	rm -rf boost_$(boost_VERSION) && \
	cd $(THIS_DIR) && \
	echo $(BOOST_VERSION) > $@

$(alembic_VERSION_FILE) : $(boost_VERSION_FILE) $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(hdf5_VERSION_FILE) $(ilmbase_VERSION_FILE) $(openexr_VERSION_FILE) $(zlib_VERSION_FILE) $(alembic_FILE)/HEAD
	@echo Building Alembic $(alembic_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf alembic && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/alembic.git" alembic && \
	cd alembic && \
	git checkout -q $(alembic_VERSION) && \
	( printf '/Werror/d\nw\nq' | ed -s CMakeLists.txt ) && \
	( printf "/INSTALL/a\nFoundation.h\n.\nw\nq" | ed -s lib/Alembic/AbcCoreLayer/CMakeLists.txt ) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DHDF5_ROOT="$(WINDOWS_PREFIX_ROOT)/hdf5" \
		-DALEMBIC_ILMBASE_LINK_STATIC:BOOL=ON \
		-DALEMBIC_LIB_USES_BOOST:BOOL=ON \
		-DALEMBIC_SHARED_LIBS:BOOL=OFF \
		-DBOOST_ROOT:STRING="$(WINDOWS_PREFIX_ROOT)/boost" \
		-DBoost_USE_STATIC_LIBS:BOOL=$(USE_STATIC_BOOST) \
		-DBUILD_SHARED_LIBS:BOOL=OFF \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/alembic" \
		-DILMBASE_ROOT="$(WINDOWS_PREFIX_ROOT)/ilmbase" \
		-DUSE_BOOSTREGEX:BOOL=ON \
		-DUSE_HDF5:BOOL=ON \
		-DUSE_MAYA:BOOL=OFF \
		-DUSE_STATIC_BOOST:BOOL=$(USE_STATIC_BOOST) \
		-DUSE_STATIC_HDF5:BOOL=ON \
		-DUSE_TESTS:BOOL=OFF \
		-DZLIB_ROOT:PATH="$(WINDOWS_PREFIX_ROOT)/zlib" \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_alembic.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_alembic.txt 2>&1 && \
	cd .. && \
	rm -rf alembic && \
	cd $(THIS_DIR) && \
	echo $(alembic_VERSION) > $@

$(cmake_VERSION_FILE) : $(cmake_FILE)
	@echo Unpacking cmake $(cmake_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf cmake-$(cmake_VERSION)-win64-x64 && \
	rm -rf $(ABSOLUTE_PREFIX_ROOT)/cmake && \
	unzip $(ABSOLUTE_SOURCES_ROOT)/cmake-$(cmake_VERSION)-win64-x64.zip > $(ABSOLUTE_PREFIX_ROOT)/log_cmake.txt 2>&1 && \
	mv cmake-$(cmake_VERSION)-win64-x64 $(ABSOLUTE_PREFIX_ROOT)/cmake && \
	chmod -R u+x $(ABSOLUTE_PREFIX_ROOT)/cmake/bin/*.exe && \
	chmod -R u+x $(ABSOLUTE_PREFIX_ROOT)/cmake/bin/*.dll && \
	cd $(THIS_DIR) && \
	echo $(cmake_VERSION) > $@

$(freetype_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(freetype_FILE)
	@echo Building FreeType $(freetype_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf $(notdir $(basename $(basename $(freetype_FILE)))) && \
	tar -xf $(freetype_FILE) && \
	cd $(notdir $(basename $(basename $(freetype_FILE)))) && \
	mkdir -p build && cd build && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/freetype" \
		.. > $(ABSOLUTE_PREFIX_ROOT)/log_freetype.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_freetype.txt 2>&1 && \
	cd ../.. && \
	rm -rf $(notdir $(basename $(basename $(freetype_FILE)))) && \
	cd $(THIS_DIR) && \
	echo $(freetype_VERSION) > $@

#embree 
$(embree_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(glut_VERSION_FILE) $(tbb_VERSION_FILE) $(zlib_VERSION_FILE) $(embree_FILE)/HEAD
	@echo Building embree $(embree_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf embree && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/$(notdir $(embree_FILE))" embree && \
	cd embree && \
	git checkout -q $(embree_VERSION) && \
	( printf '/FIND_PACKAGE_HANDLE_STANDARD_ARGS/-\na\nSET(TBB_INCLUDE_DIR $(WINDOWS_PREFIX_ROOT)/tbb/include)\n.\nw\nq\n' | ed -s common/cmake/FindTBB.cmake ) && \
	( printf '/FIND_PACKAGE_HANDLE_STANDARD_ARGS/-\na\nSET(TBB_LIBRARY $(WINDOWS_PREFIX_ROOT)/tbb/lib/tbb.lib)\n.\nw\nq\n' | ed -s common/cmake/FindTBB.cmake ) && \
	( printf '/FIND_PACKAGE_HANDLE_STANDARD_ARGS/-\na\nSET(TBB_LIBRARY_MALLOC $(WINDOWS_PREFIX_ROOT)/tbb/lib/tbbmalloc.lib)\n.\nw\nq\n' | ed -s common/cmake/FindTBB.cmake ) && \
	( printf '/INSTALL(PROGRAMS/d\nw\nq\n' | ed -s common/cmake/FindTBB.cmake ) && \
	( printf '/INSTALL(PROGRAMS/d\nw\nq\n' | ed -s common/cmake/FindTBB.cmake ) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/embree" \
		-DEMBREE_ISPC_SUPPORT:BOOL=OFF \
		-DEMBREE_STATIC_LIB:BOOL=OFF \
		-DEMBREE_STATIC_LIB:BOOL=ON \
		-DGLUT_INCLUDE_DIR:PATH="$(WINDOWS_PREFIX_ROOT)/glut/include" \
		-DGLUT_glut_LIBRARY:PATH="$(WINDOWS_PREFIX_ROOT)/glut/lib/freeglut_static.lib" \
		-DTBB_INCLUDE_DIR="$(WINDOWS_PREFIX_ROOT)/tbb/include" \
		-DTBB_LIBRARY="$(WINDOWS_PREFIX_ROOT)/tbb/lib/tbb.lib" \
		-DTBB_LIBRARY_MALLOC="$(WINDOWS_PREFIX_ROOT)/tbb/lib/tbbmalloc.lib" \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_embree.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_embree.txt 2>&1 && \
	cd .. && \
	rm -rf embree && \
	cd $(THIS_DIR) && \
	echo $(embree_VERSION) > $@

# glew
# Edits:
# - define GLEW_STATIC
# link glewinfo and visualinfo statically
$(glew_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(glew_FILE)
	@echo Building glew $(glew_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf $(notdir $(basename $(glew_FILE))) && \
	tar zxf $(ABSOLUTE_SOURCES_ROOT)/$(notdir $(glew_FILE)) && \
	cd $(notdir $(basename $(glew_FILE))) && \
	( printf "0a\n#define GLEW_STATIC\n.\nw\nq\n" | ed -s include/GL/glew.h ) && \
	( printf "0a\n#define GLEW_STATIC\n.\nw\nq\n" | ed -s include/GL/wglew.h ) && \
	( printf "/target_link_libraries.*glewinfo/s/glew)/glew_s)/\nw\nq" | ed -s build/cmake/CMakeLists.txt ) && \
	( printf "/target_link_libraries.*visualinfo/s/glew)/glew_s)/\nw\nq" | ed -s build/cmake/CMakeLists.txt ) && \
	( printf "/CMAKE_DEBUG_POSTFIX/d\nw\nq" | ed -s build/cmake/CMakeLists.txt ) && \
	cd build && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/glew" \
		./cmake > $(ABSOLUTE_PREFIX_ROOT)/log_glew.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_glew.txt 2>&1 && \
	cd ../.. && \
	rm -rf $(notdir $(basename $(glew_FILE))) && \
	cd $(THIS_DIR) && \
	echo $(glew_VERSION) > $@


# glfw
$(glfw_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(glfw_FILE)/HEAD
	@echo Building glfw $(glfw_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf $(notdir $(basename $(glfw_FILE))) && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/$(notdir $(glfw_FILE))" $(notdir $(basename $(glfw_FILE))) && \
	cd $(notdir $(basename $(glfw_FILE))) && \
	git checkout -q $(glfw_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DGLFW_BUILD_DOCS:BOOL=OFF \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/glfw" \
		-DZLIB_ROOT:PATH="$(WINDOWS_PREFIX_ROOT)/zlib" \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_glfw.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_glfw.txt 2>&1 && \
	cd .. && \
	rm -rf $(notdir $(basename $(glfw_FILE))) && \
	cd $(THIS_DIR) && \
	echo $(glfw_VERSION) > $@


# glut
$(glut_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(glut_FILE)
	@echo Building glut $(glut_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf $(notdir $(basename $(basename $(glut_FILE)))) && \
	tar -xf $(ABSOLUTE_SOURCES_ROOT)/$(notdir $(glut_FILE)) && \
	cd $(notdir $(basename $(basename $(glut_FILE)))) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/glut" \
		-DFREEGLUT_BUILD_DEMOS:BOOL=OFF \
		-DFREEGLUT_BUILD_SHARED_LIBS:BOOL=OFF \
		-DINSTALL_PDB:BOOL=ON \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_glut.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_glut.txt 2>&1 && \
	cd .. && \
	rm -rf $(notdir $(basename $(basename $(glut_FILE)))) && \
	cd $(THIS_DIR) && \
	echo $(glut_VERSION) > $@


# HDF5
$(hdf5_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(zlib_VERSION_FILE) $(hdf5_FILE)
	@echo Building HDF5 $(hdf5_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf hdf5-$(hdf5_VERSION) && \
	tar -xf $(ABSOLUTE_SOURCES_ROOT)/hdf5-$(hdf5_VERSION).tar.gz && \
	cd hdf5-$(hdf5_VERSION) && \
	( test $$OS != linux || if [ -f release_docs/USING_CMake.txt ] ; then cp release_docs/USING_CMake.txt release_docs/Using_CMake.txt ; fi ) && \
	( if [ ! -f release_docs/USING_CMake.txt ] ; then touch release_docs/USING_CMake.txt ; fi ) && \
	( if [ ! -f release_docs/Using_CMake.txt ] ; then touch release_docs/Using_CMake.txt ; fi ) && \
	( printf '/H5_HAVE_TIMEZONE/s/1/0/\nw\nq' | ed -s config/cmake/ConfigureChecks.cmake ) && \
	( printf '/"\/MD"/s/MD/MT/\nw\nq' | ed -s config/cmake/HDFMacros.cmake ) && \
	( printf '/HDF5_PRINTF_LL/s/(.*)/(HDF5_PRINTF_LL)/\nw\nq' | ed -s config/cmake/ConfigureChecks.cmake ) && \
	mkdir build && cd build && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DBUILD_SHARED_LIBS:BOOL=OFF \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/hdf5" \
		-DZLIB_ROOT:PATH="$(WINDOWS_PREFIX_ROOT)/zlib" \
		-DZLIB_USE_EXTERNAL:BOOL=ON \
		.. > $(ABSOLUTE_PREFIX_ROOT)/log_hdf5.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_hdf5.txt 2>&1 && \
	cd ../.. && \
	rm -rf hdf5-$(hdf5_VERSION) && \
	cd $(THIS_DIR) && \
	echo $(hdf5_VERSION) > $@

# jom
$(jom_VERSION_FILE) : $(cmake_VERSION_FILE) $(qt5base_VERSION_FILE) $(jom_FILE)/HEAD
	@echo Building jom $(jom_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf $(notdir $(basename $(jom_FILE))) && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/$(notdir $(jom_FILE))" $(notdir $(basename $(jom_FILE))) && \
	cd $(notdir $(basename $(jom_FILE))) && \
	git checkout -q $(jom_VERSION) && \
	( printf "/target_link_libraries/s/)/ Winmm Mincore $(subst /,\/,$(WINDOWS_PREFIX_ROOT))\/qt5base\/lib\/qtpcre2.lib)/\nw\n" | ed -s CMakeLists.txt ) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-G "NMake Makefiles" \
		-DQt5Core_DIR:PATH="$(WINDOWS_PREFIX_ROOT)/qt5base/lib/cmake/Qt5Core" \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/jom" \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_jom.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_jom.txt 2>&1 && \
	cd .. && \
	rm -rf $(notdir $(basename $(jom_FILE))) && \
	cd $(THIS_DIR) && \
	echo $(jom_VERSION) > $@

# jpeg
$(jpeg_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(jpeg_FILE)/HEAD
	@echo Building jpeg $(jpeg_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf jpeg && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/libjpeg-turbo.git" jpeg && \
	cd jpeg && \
	git checkout -q $(jpeg_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DENABLE_SHARED:BOOL=OFF \
		-DENABLE_STATIC:BOOL=ON \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/jpeg" \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_jpeg.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_jpeg.txt 2>&1 && \
	cd .. && \
	rm -rf jpeg && \
	cd $(THIS_DIR) && \
	echo $(jpeg_VERSION) > $@


# jsoncpp
$(jsoncpp_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(zlib_VERSION_FILE) $(jsoncpp_FILE)/HEAD
	@echo Building jsoncpp $(jsoncpp_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf jsoncpp && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/jsoncpp.git" jsoncpp && \
	cd jsoncpp && \
	git checkout -q $(jsoncpp_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/jsoncpp" \
		-DZLIB_ROOT:PATH="$(WINDOWS_PREFIX_ROOT)/zlib" \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_jsoncpp.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_jsoncpp.txt 2>&1 && \
	cd .. && \
	rm -rf jsoncpp && \
	cd $(THIS_DIR) && \
	echo $(jsoncpp_VERSION) > $@

$(ilmbase_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(ilmbase_FILE)
	@echo Building IlmBase $(ilmbase_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf ilmbase-$(ilmbase_VERSION) && \
	tar -xf $(ABSOLUTE_SOURCES_ROOT)/ilmbase-$(ilmbase_VERSION).tar.gz && \
	cd ilmbase-$(ilmbase_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DBUILD_SHARED_LIBS:BOOL=OFF \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/ilmbase" \
		-DNAMESPACE_VERSIONING:BOOL=ON \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_ilmbase.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_ilmbase.txt 2>&1 && \
	cd .. && \
	rm -rf ilmbase-$(ilmbase_VERSION) && \
	cd $(THIS_DIR) && \
	echo $(ilmbase_VERSION) > $@


# OpenImageIO
# Edits:
# - Defining OIIO_STATIC_BUILD to avoid specifying it everywhere
# - std::locale segfault fix
# - Python module
$(oiio_VERSION_FILE) : $(boost_VERSION_FILE) $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(freetype_VERSION_FILE) $(ilmbase_VERSION_FILE) $(jpeg_VERSION_FILE) $(openexr_VERSION_FILE) $(png_VERSION_FILE) $(tiff_VERSION_FILE) $(zlib_VERSION_FILE) $(oiio_FILE)/HEAD
	@echo Building OpenImageIO $(oiio_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf oiio && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/oiio.git" oiio && \
	cd oiio && \
	git checkout -q $(oiio_VERSION) && \
	( printf '/pragma once/a\n#ifndef OIIO_STATIC_BUILD\n#define OIIO_STATIC_BUILD\n#endif\n.\nw\nq\n' | ed -s src/include/OpenImageIO/export.h ) && \
	( printf '/libturbojpeg/s/libturbojpeg/turbojpeg-static/\nw\nq' | ed -s src/cmake/modules/FindJPEGTurbo.cmake ) && \
	( printf '/\/W1/s/W1/bigobj/\nw\nq' | ed -s src/cmake/compiler.cmake ) && \
	( printf '/Boost_USE_STATIC_LIBS/d\nw\nq' | ed -s src/cmake/compiler.cmake ) && \
	( printf '/Boost_USE_STATIC_LIBS/d\nw\nq' | ed -s src/cmake/compiler.cmake ) && \
	( printf '/Boost_USE_STATIC_LIBS/d\nw\nq' | ed -s src/cmake/externalpackages.cmake ) && \
	mkdir build && cd build && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DBOOST_ROOT="$(WINDOWS_PREFIX_ROOT)/boost" \
		-DBUILDSTATIC:BOOL=ON \
		-DBoost_USE_STATIC_LIBS:BOOL=$(USE_STATIC_BOOST) \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/oiio" \
		-DFREETYPE_INCLUDE_PATH="$(WINDOWS_PREFIX_ROOT)/freetype/include/freetype2" \
		-DFREETYPE_PATH="$(WINDOWS_PREFIX_ROOT)/freetype" \
		-DILMBASE_HOME="$(WINDOWS_PREFIX_ROOT)/ilmbase" \
		-DJPEGTURBO_PATH="$(WINDOWS_PREFIX_ROOT)/jpeg" \
		-DLINKSTATIC:BOOL=ON \
		-DOIIO_BUILD_TESTS:BOOL=OFF \
		-DOPENEXR_HOME="$(WINDOWS_PREFIX_ROOT)/openexr" \
		-DPNG_LIBRARY="$(WINDOWS_PREFIX_ROOT)/png/lib/libpng16_static.lib" \
		-DPNG_PNG_INCLUDE_DIR="$(WINDOWS_PREFIX_ROOT)/png/include" \
		-DTIFF_INCLUDE_DIR="$(WINDOWS_PREFIX_ROOT)/tiff/include" \
		-DTIFF_LIBRARY="$(WINDOWS_PREFIX_ROOT)/tiff/lib/libtiff.lib" \
		-DUSE_FREETYPE:BOOL=ON \
		-DUSE_GIF:BOOL=OFF \
		-DUSE_JPEGTURBO:BOOL=ON \
		-DUSE_NUKE:BOOL=OFF \
		-DVERBOSE:BOOL=ON \
		-DZLIB_ROOT="$(WINDOWS_PREFIX_ROOT)/zlib" \
		.. > $(ABSOLUTE_PREFIX_ROOT)/log_oiio.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_oiio.txt 2>&1 && \
	cd ../.. && \
	rm -rf oiio && \
	cd $(THIS_DIR) && \
	echo $(oiio_VERSION) > $@


$(openexr_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(ilmbase_VERSION_FILE) $(zlib_VERSION_FILE) $(openexr_FILE)
	@echo Building OpenEXR $(openexr_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf openexr-$(openexr_VERSION) && \
	tar -xf $(ABSOLUTE_SOURCES_ROOT)/openexr-$(openexr_VERSION).tar.gz && \
	cd openexr-$(openexr_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DBUILD_SHARED_LIBS:BOOL=OFF \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/openexr" \
		-DILMBASE_PACKAGE_PREFIX:PATH="$(WINDOWS_PREFIX_ROOT)/ilmbase" \
		-DNAMESPACE_VERSIONING:BOOL=ON \
		-DZLIB_ROOT:PATH="$(WINDOWS_PREFIX_ROOT)/zlib" \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_openexr.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_openexr.txt 2>&1 && \
	cd .. && \
	rm -rf openexr-$(openexr_VERSION) && \
	cp $(ABSOLUTE_PREFIX_ROOT)/ilmbase/lib/*.lib $(ABSOLUTE_PREFIX_ROOT)/openexr/lib && \
	cd $(THIS_DIR) && \
	echo $(openexr_VERSION) > $@


# OpenSubdiv
$(opensubd_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(glew_VERSION_FILE) $(glfw_VERSION_FILE) $(ptex_VERSION_FILE) $(tbb_VERSION_FILE) $(zlib_VERSION_FILE) $(opensubd_FILE)/HEAD
	@echo Building OpenSubdiv $(opensubd_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf $(notdir $(basename $(opensubd_FILE))) && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/$(notdir $(opensubd_FILE))" $(notdir $(basename $(opensubd_FILE))) && \
	cd $(notdir $(basename $(opensubd_FILE))) && \
	git checkout -q $(opensubd_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	( printf "/osd_dynamic_cpu/s/osd_dynamic_cpu/osd_static_gpu/\nw\nq" | ed -s CMakeLists.txt ) && \
	( printf "/osd_dynamic_gpu/s/osd_dynamic_gpu/osd_static_cpu/\nw\nq" | ed -s CMakeLists.txt ) && \
	( printf "/if.*NOT.*NOT/s/(/( 0 AND /\nw\nq" | ed -s opensubdiv/CMakeLists.txt ) && \
	( printf "/\/WX/d\nw\nq" | ed -s CMakeLists.txt ) && \
	( printf "/glew32s/s/glew32s/libglew32/\nw\nq" | ed -s cmake/FindGLEW.cmake ) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/opensubdiv" \
		-DGLFW_LOCATION:PATH="$(WINDOWS_PREFIX_ROOT)/glfw" \
		-DGLEW_LOCATION:PATH="$(WINDOWS_PREFIX_ROOT)/glew" \
		-DNO_GLTESTS:BOOL=ON \
		-DNO_TESTS:BOOL=ON \
		-DNO_TUTORIALS:BOOL=ON \
		-DMSVC_STATIC_CRT:BOOL=ON \
		-DPTEX_LOCATION:PATH="$(WINDOWS_PREFIX_ROOT)/ptex" \
		-DPYTHON_EXECUTABLE=$(PYTHON_BIN) \
		-DTBB_LOCATION:PATH="$(WINDOWS_PREFIX_ROOT)/tbb" \
		-DZLIB_ROOT:PATH="$(WINDOWS_PREFIX_ROOT)/zlib" \
		-DNO_OMP=1 \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_opensubdiv.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_opensubdiv.txt 2>&1 && \
	cd .. && \
	rm -rf $(notdir $(basename $(opensubd_FILE))) && \
	cd $(THIS_DIR) && \
	echo $(opensubd_VERSION) > $@

# perl
$(perl_VERSION_FILE) : $(perl_FILE)
	@echo Building Perl $(perl_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf $(notdir $(basename $(perl_FILE))) && \
	tar -xf $(ABSOLUTE_SOURCES_ROOT)/perl-$(perl_VERSION).tar.gz && \
	cd perl-$(perl_VERSION)/win32 && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	env -u MAKE -u MAKEFLAGS nmake \
		CCTYPE=MSVC141 \
		config.h > $(ABSOLUTE_PREFIX_ROOT)/log_perl.txt 2>&1 && \
	env -u MAKE -u MAKEFLAGS nmake \
		CCTYPE=MSVC141 \
		../perlio.i >> $(ABSOLUTE_PREFIX_ROOT)/log_perl.txt 2>&1 && \
	env -u MAKE -u MAKEFLAGS nmake \
		CCTYPE=MSVC141 \
		INST_TOP="$(subst /,\,$(WINDOWS_PREFIX_ROOT))\perl" \
		install >> $(ABSOLUTE_PREFIX_ROOT)/log_perl.txt 2>&1 && \
	cd ../.. && \
	rm -rf $(notdir $(basename $(perl_FILE))) && \
	cd $(THIS_DIR) && \
	echo $(perl_VERSION) > $@

# png
$(png_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(zlib_VERSION_FILE) $(png_FILE)/HEAD
	@echo Building png $(png_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf png && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/code" png && \
	cd png && \
	git checkout -q $(png_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DPNG_SHARED:BOOL=OFF \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/png" \
		-DZLIB_ROOT:PATH="$(WINDOWS_PREFIX_ROOT)/zlib" \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_png.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_png.txt 2>&1 && \
	cd .. && \
	rm -rf png && \
	cd $(THIS_DIR) && \
	echo $(png_VERSION) > $@


# Ptex
$(ptex_VERSION_FILE) : $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(ptex_FILE)/HEAD
	@echo Building Ptex $(ptex_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf $(notdir $(basename $(ptex_FILE))) && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/$(notdir $(ptex_FILE))" $(notdir $(basename $(ptex_FILE))) && \
	cd $(notdir $(basename $(ptex_FILE))) && \
	git checkout -q $(ptex_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	( printf "2a\n#define PTEX_STATIC\n.\nw\nq\n" | ed -s src/ptex/Ptexture.h ) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/ptex" \
		-DZLIB_ROOT:PATH="$(WINDOWS_PREFIX_ROOT)/zlib" \
		. > $(ABSOLUTE_PREFIX_ROOT)/log_ptex.txt 2>&1 && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) >> $(ABSOLUTE_PREFIX_ROOT)/log_ptex.txt 2>&1 && \
	cd .. && \
	rm $(ABSOLUTE_PREFIX_ROOT)/ptex/lib/*.dll && \
	rm -rf $(notdir $(basename $(ptex_FILE))) && \
	cd $(THIS_DIR) && \
	echo $(ptex_VERSION) > $@

$(qt5base_VERSION_FILE) : $(perl_VERSION_FILE) $(qt5base_FILE)/HEAD
	@echo Building Qt5 Base $(qt5base_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf $(notdir $(basename $(qt5base_FILE))) && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/$(notdir $(qt5base_FILE))" $(notdir $(basename $(qt5base_FILE))) && \
	cd $(notdir $(basename $(qt5base_FILE))) && \
	git checkout -q $(qt5base_VERSION) && \
	( printf "g/-MD/s/-MD/-MT/g\nw\n" | ed -s mkspecs/common/msvc-desktop.conf ) && \
	( printf '/^QMAKE_CFLAGS_RELEASE[[:space:]]/a\n -D_SECURE_SCL=0\n.\n-,.j\nw\n' | ed -s mkspecs/common/msvc-desktop.conf ) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/perl/bin:$$PATH && \
	env -u MAKE -u MAKEFLAGS cmd /C configure.bat \
		-confirm-license \
		-no-cups \
		-no-directwrite \
		-no-gif \
		-no-gui \
		-no-libjpeg \
		-no-openssl \
		-no-qml-debug \
		-no-sql-mysql \
		-no-sql-sqlite \
		-no-widgets \
		-nomake examples \
		-nomake tests \
		-nomake tools \
		-opengl desktop \
		-opensource \
		-prefix "$(WINDOWS_PREFIX_ROOT)/qt5base" \
		-qt-freetype \
		-qt-libpng \
		-qt-pcre \
		-release \
		-static \
		-mp > $(ABSOLUTE_PREFIX_ROOT)/log_gt5base.txt 2>&1 && \
	env -u MAKE -u MAKEFLAGS nmake >> $(ABSOLUTE_PREFIX_ROOT)/log_gt5base.txt 2>&1 && \
	env -u MAKE -u MAKEFLAGS nmake install >> $(ABSOLUTE_PREFIX_ROOT)/log_gt5base.txt 2>&1 && \
	cd .. && \
	echo rm -rf $(notdir $(basename $(qt5base_FILE))) && \
	cd $(THIS_DIR) && \
	echo $(qt5base_VERSION) > $@

# tbb
$(tbb_VERSION_FILE) : $(tbb_FILE)
	@echo Building tbb $(tbb_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf tbb$(tbb_VERSION) && \
	tar zxf $(ABSOLUTE_SOURCES_ROOT)/$(notdir $(tbb_FILE)) && \
	cd tbb$(tbb_VERSION) && \
	cmd /C msbuild build/vs2012/makefile.sln \
		/p:configuration=$(CMAKE_BUILD_TYPE)-MT \
		/p:platform=x64 \
		/p:PlatformToolset=v141 > $(ABSOLUTE_PREFIX_ROOT)/log_tbb.txt 2>&1 && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT)/tbb/include && \
	cp -R include/tbb $(ABSOLUTE_PREFIX_ROOT)/tbb/include && \
	cmd /C link /lib /machine:x64 /out:tbb.lib \
		build/vs2012/x64/tbb/$(CMAKE_BUILD_TYPE)-MT/*.obj >> $(ABSOLUTE_PREFIX_ROOT)/log_tbb.txt 2>&1 && \
	cmd /C link /lib /machine:x64 /out:tbbmalloc.lib \
		build/vs2012/x64/tbbmalloc/$(CMAKE_BUILD_TYPE)-MT/*.obj >> $(ABSOLUTE_PREFIX_ROOT)/log_tbb.txt 2>&1 && \
	cmd /C link /lib /machine:x64 /out:tbbmalloc_proxy.lib \
		build/vs2012/x64/tbbmalloc_proxy/$(CMAKE_BUILD_TYPE)-MT/*.obj >> $(ABSOLUTE_PREFIX_ROOT)/log_tbb.txt 2>&1 && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT)/tbb/lib && \
	cp *.lib $(ABSOLUTE_PREFIX_ROOT)/tbb/lib && \
	cd .. && \
	rm -rf tbb$(tbb_VERSION) && \
	cd $(THIS_DIR) && \
	echo $(tbb_VERSION) > $@


$(tiff_VERSION_FILE) : $(ZLIB_VERSION_FILE) $(tiff_FILE) $(jpeg_VERSION_FILE) $(zlib_VERSION_FILE)
	@echo Building tiff $(tiff_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf tiff-$(tiff_VERSION) && \
	tar -xf $(ABSOLUTE_SOURCES_ROOT)/tiff-$(tiff_VERSION).tar.gz && \
	cd tiff-$(tiff_VERSION) && \
	( printf '/OPTFLAGS/s/MD/MT/\nw\nq' | ed -s nmake.opt ) && \
	env -u MAKE -u MAKEFLAGS nmake /f Makefile.vc \
		JPEG_SUPPORT=1 \
		JPEG_INCLUDE=-I"$(WINDOWS_PREFIX_ROOT)/jpeg/include" \
		JPEG_LIB="$(WINDOWS_PREFIX_ROOT)/jpeg/lib/jpeg-static.lib $(WINDOWS_PREFIX_ROOT)/zlib/lib/z.lib" \
		ZLIB_SUPPORT=1 \
		ZLIB_INCLUDE=-I"$(WINDOWS_PREFIX_ROOT)/zlib/include" \
		ZLIB_LIB="$(WINDOWS_PREFIX_ROOT)/zlib/lib/z.lib" > $(ABSOLUTE_PREFIX_ROOT)/log_tiff.txt 2>&1 && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT)/tiff/bin && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT)/tiff/include && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT)/tiff/lib && \
	cp tools/*.exe $(ABSOLUTE_PREFIX_ROOT)/tiff/bin && \
	cp libtiff/libtiff.lib $(ABSOLUTE_PREFIX_ROOT)/tiff/lib && \
	cp libtiff/libtiff.pdb $(ABSOLUTE_PREFIX_ROOT)/tiff/lib && \
	cp libtiff/libtiff.ilk $(ABSOLUTE_PREFIX_ROOT)/tiff/lib && \
	cp libtiff/*.h* $(ABSOLUTE_PREFIX_ROOT)/tiff/include && \
	cd .. && \
	rm -rf tiff-$(tiff_VERSION) && \
	cd $(THIS_DIR) && \
	echo $(openexr_VERSION) > $@

DYNAMIC_EXT := .lib
BOOST_NAMESPACE := boost
ifeq "$(BOOST_LINK)" "shared"
BOOST_PREFIX :=
else
BOOST_PREFIX := lib
endif
OIIO_LIBS = \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/png/lib/libpng16_static.lib" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/tiff/lib/libtiff.lib" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/jpeg/lib/turbojpeg-static.lib" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/openexr/lib/IlmImf-2_2.lib" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/openexr/lib/Imath-2_2.lib" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/openexr/lib/Iex-2_2.lib" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/openexr/lib/Half.lib" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/openexr/lib/IlmThread-2_2.lib" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/ptex/lib/Ptex.lib" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/boost/lib/$(BOOST_PREFIX)$(BOOST_NAMESPACE)_python$(DYNAMIC_EXT)" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/boost/lib/$(BOOST_PREFIX)$(BOOST_NAMESPACE)_filesystem$(DYNAMIC_EXT)" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/boost/lib/$(BOOST_PREFIX)$(BOOST_NAMESPACE)_regex$(DYNAMIC_EXT)" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/boost/lib/$(BOOST_PREFIX)$(BOOST_NAMESPACE)_system$(DYNAMIC_EXT)" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/boost/lib/$(BOOST_PREFIX)$(BOOST_NAMESPACE)_thread$(DYNAMIC_EXT)" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/boost/lib/$(BOOST_PREFIX)$(BOOST_NAMESPACE)_chrono$(DYNAMIC_EXT)" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/boost/lib/$(BOOST_PREFIX)$(BOOST_NAMESPACE)_date_time$(DYNAMIC_EXT)" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/boost/lib/$(BOOST_PREFIX)$(BOOST_NAMESPACE)_atomic$(DYNAMIC_EXT)" \
	"$(subst \,/,$(WINDOWS_PREFIX_ROOT))/zlib/lib/z.lib"

TBB_LIBRARY := "$(WINDOWS_PREFIX_ROOT)/tbb/lib"
TBB_ROOT_DIR := "$(WINDOWS_PREFIX_ROOT)/tbb/include"
MAYA_ROOT := "C:/Program Files/Autodesk/Maya2016"

$(usd_VERSION_FILE) : $(boost_VERSION_FILE) $(cmake_VERSION_FILE) $(jom_VERSION_FILE) $(glut_VERSION_FILE) $(ilmbase_VERSION_FILE) $(oiio_VERSION_FILE) $(openexr_VERSION_FILE) $(opensubd_VERSION_FILE) $(ptex_VERSION_FILE) $(tbb_VERSION_FILE) $(usd_FILE)/HEAD
	@echo Building usd $(usd_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf $(notdir $(basename $(usd_FILE))) && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/$(notdir $(usd_FILE))" $(notdir $(basename $(usd_FILE))) && \
	cd $(notdir $(basename $(usd_FILE))) && \
	git checkout -q $(usd_VERSION) && \
	echo Patching for supporting static OIIO... && \
	( for f in $(OIIO_LIBS); do ( printf "\044a\nlist(APPEND OIIO_LIBRARIES \"$$f\")\n.\nw\nq" | ed -s cmake/modules/FindOpenImageIO.cmake ); done ) && \
	( printf "/find_library.*OPENEXR_.*_LIBRARY/a\nNAMES\n\044{OPENEXR_LIB}-2_2\n.\nw\nq" | ed -s cmake/modules/FindOpenEXR.cmake ) && \
	( printf "/HDF5 REQUIRED/+\nd\nd\nd\nw\nq" | ed -s cmake/defaults/Packages.cmake ) && \
	( printf "/BOOST_ALL_DYN_LINK/d\nw\nq" | ed -s cmake/defaults/msvcdefaults.cmake ) && \
	( printf "/OPENEXR_DLL/d\nw\nq" | ed -s cmake/defaults/msvcdefaults.cmake ) && \
	echo Patching for supporting MSVC2017... && \
	( printf "/glew32s/s/glew32s/libglew32/\nw\nq" | ed -s cmake/modules/FindGLEW.cmake ) && \
	( printf "/Zc:rvalueCast/d\nd\nd\na\nset(_PXR_CXX_FLAGS \"\044{_PXR_CXX_FLAGS} /Zc:rvalueCast /Zc:strictStrings /Zc:inline\")\n.\nw\nq" | ed -s cmake/defaults/msvcdefaults.cmake ) && \
	echo Patching for Maya 2016 support... && \
	( printf "/Program Files.*Maya2017/d\nw\nq" | ed -s cmake/modules/FindMaya.cmake ) && \
	( printf "/find_package_handle_standard_args/\n/MAYA_EXECUTABLE/d\nw\nq" | ed -s cmake/modules/FindMaya.cmake ) && \
	echo Cant irnore Unresolved_external_symbol_error_is_expected_Please_ignore because it always fails... && \
	( printf "/Unresolved_external_symbol_error_is_expected_Please_ignore/d\ni\nint Unresolved_external_symbol_error_is_expected_Please_ignore()\n{return 0;}\n.\nw\nq" | ed -s pxr/base/lib/plug/testenv/TestPlugDsoUnloadable.cpp ) && \
	( test ! $(USE_STATIC_BOOST) == ON || echo Dont skip plugins when building static libraries... ) && \
	( test ! $(USE_STATIC_BOOST) == ON || printf "/Skipping plugin/\nd\nd\na\nset(args_TYPE \"STATIC\")\n.\nw\nq" | ed -s cmake/macros/Public.cmake ) && \
	( test ! $(USE_STATIC_BOOST) == ON || printf "/CMAKE_SHARED_LIBRARY_SUFFIX/s/CMAKE_SHARED_LIBRARY_SUFFIX/CMAKE_STATIC_LIBRARY_SUFFIX/\nw\nq" | ed -s cmake/macros/Public.cmake ) && \
	echo Set Catmull-Clark as default subdivision scheme for all the alembics. It's temporary, while Hydra doesn't consider normals... && \
	( printf "/UsdGeomTokens->subdivisionScheme/+2\ns/none/catmullClark/\nw\nq" | ed -s pxr/usd/plugin/usdAbc/alembicReader.cpp ) && \
	echo Skip extra stuff because it fails... && \
	( printf "/add_subdirectory(extras)/d\nw\n" | ed -s CMakeLists.txt ) && \
	mkdir -p build && cd build && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	export PATH=$(ABSOLUTE_PREFIX_ROOT)/jom/bin:$$PATH && \
	$(CMAKE) \
		$(COMMON_CMAKE_FLAGS) \
		-DALEMBIC_DIR=$(WINDOWS_PREFIX_ROOT)/alembic \
		-DBOOST_ROOT:PATH="$(WINDOWS_PREFIX_ROOT)/boost" \
		-DBUILD_SHARED_LIBS:BOOL=OFF \
		-DBoost_USE_STATIC_LIBS:BOOL=$(USE_STATIC_BOOST) \
		-DCMAKE_INSTALL_PREFIX="$(WINDOWS_PREFIX_ROOT)/usd" \
		-DGLEW_LOCATION:PATH="$(WINDOWS_PREFIX_ROOT)/glew" \
		-DGLFW_LOCATION:PATH="$(WINDOWS_PREFIX_ROOT)/glfw" \
		-DGLUT_Xmu_LIBRARY= \
		-DHDF5_ROOT=$(WINDOWS_PREFIX_ROOT)/hdf5 \
		-DMAYA_LOCATION:PATH=$(MAYA_ROOT) \
		-DPYSIDE_BIN_DIR:PATH=$(MAYA_ROOT)/bin \
		-DOIIO_LOCATION:PATH="$(WINDOWS_PREFIX_ROOT)/oiio" \
		-DOPENEXR_BASE_DIR:PATH="$(WINDOWS_PREFIX_ROOT)/ilmbase" \
		-DOPENEXR_LOCATION:PATH="$(WINDOWS_PREFIX_ROOT)/openexr" \
		-DOPENSUBDIV_ROOT_DIR:PATH="$(WINDOWS_PREFIX_ROOT)/opensubdiv" \
		-DPTEX_LOCATION:PATH="$(WINDOWS_PREFIX_ROOT)/ptex" \
		-DPXR_BUILD_ALEMBIC_PLUGIN:BOOL=OFF \
		-DPXR_BUILD_IMAGING:BOOL=ON \
		-DPXR_BUILD_MAYA_PLUGIN:BOOL=$(BUILD_USD_MAYA_PLUGIN) \
		-DPXR_BUILD_MONOLITHIC:BOOL=$(BUILD_USD_MAYA_PLUGIN) \
		-DPXR_BUILD_TESTS:BOOL=OFF \
		-DPXR_BUILD_USD_IMAGING:BOOL=ON \
		-DPYTHON_EXECUTABLE=$(PYTHON_BIN) \
		-DTBB_LIBRARY=$(TBB_LIBRARY) \
		-DTBB_ROOT_DIR=$(TBB_ROOT_DIR) \
		-DZLIB_ROOT:PATH="$(WINDOWS_PREFIX_ROOT)/zlib" \
		-D_GLUT_INC_DIR:PATH="$(WINDOWS_PREFIX_ROOT)/glut/include" \
		-D_GLUT_glut_LIB_DIR:PATH="$(WINDOWS_PREFIX_ROOT)/glut/lib" \
		.. && \
	$(CMAKE) \
		--build . \
		--target install \
		--config $(CMAKE_BUILD_TYPE) && \
	( test ! $(USE_STATIC_BOOST) == OFF || echo Including boost shared libraries... ) && \
	( test ! $(USE_STATIC_BOOST) == OFF || cp $(ABSOLUTE_PREFIX_ROOT)/boost/lib/*.dll $(ABSOLUTE_PREFIX_ROOT)/usd/lib ) && \
	cd ../.. && \
	rm -rf $(notdir $(basename $(usd_FILE))) && \
	cd $(THIS_DIR) && \
	echo $(usd_VERSION) > $@

usd-$(usd_VERSION)-$(BOOST_LINK).tar.xz : $(usd_VERSION_FILE)
	@echo Archiving $@ && \
	tar cfJ $@ -C $(ABSOLUTE_PREFIX_ROOT) usd

# libz
$(zlib_VERSION_FILE) : $(zlib_FILE)/HEAD
	@echo Building zlib $(zlib_VERSION) && \
	mkdir -p $(ABSOLUTE_BUILD_ROOT) && cd $(ABSOLUTE_BUILD_ROOT) && \
	rm -rf zlib && \
	git clone -q --no-checkout "$(WINDOWS_SOURCES_ROOT)/$(notdir $(zlib_FILE))" zlib && \
	cd zlib && \
	git checkout -q $(zlib_VERSION) && \
	mkdir -p $(ABSOLUTE_PREFIX_ROOT) && \
	env -u MAKE -u MAKEFLAGS nmake -f win32/Makefile.msc "CFLAGS=/nologo $(CL_MODE_FLAGS) /GR /EHsc" zlib.lib > $(ABSOLUTE_PREFIX_ROOT)/log_zlib.txt 2>&1 && \
	cd $(ABSOLUTE_PREFIX_ROOT) && mkdir -p zlib/include && mkdir -p zlib/lib && \
	cp $(ABSOLUTE_BUILD_ROOT)/zlib/zlib.lib zlib/lib/z.lib && \
	cp $(ABSOLUTE_BUILD_ROOT)/zlib/zlib.h zlib/include/ && \
	cp $(ABSOLUTE_BUILD_ROOT)/zlib/zconf.h zlib/include/ && \
	rm -rf $(ABSOLUTE_BUILD_ROOT)/zlib && \
	cd $(THIS_DIR) && \
	echo $(zlib_VERSION) > $@

