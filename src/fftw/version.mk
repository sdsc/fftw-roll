ifndef ROLLCOMPILER
  ROLLCOMPILER = gnu
endif
COMPILERNAME := $(firstword $(subst /, ,$(ROLLCOMPILER)))

ifndef ROLLMPI
  ROLLMPI = rocks-openmpi
endif
MPINAME := $(firstword $(subst /, ,$(ROLLMPI)))

NAME           = sdsc-fftw_$(COMPILERNAME)_$(ROLLMPI)
VERSION        = 3.3.6
RELEASE        = 0
PKGROOT        = /opt/fftw/$(VERSION)/$(COMPILERNAME)/$(MPINAME)

SRC_SUBDIR     = fftw

SOURCE_NAME    = fftw
SOURCE_VERSION = $(VERSION)-pl2
SOURCE_SUFFIX  = tar.gz
SOURCE_PKG     = $(SOURCE_NAME)-$(SOURCE_VERSION).$(SOURCE_SUFFIX)
SOURCE_DIR     = $(SOURCE_PKG:%.$(SOURCE_SUFFIX)=%)

TAR_GZ_PKGS    = $(SOURCE_PKG)

RPM.EXTRAS     = "AutoProv:No\\nAutoReq:No\\n%define __os_install_post /usr/lib/rpm/brp-compress"
RPM.PREFIX     = $(PKGROOT)
