ifndef ROLLCOMPILER
  ROLLCOMPILER = gnu
endif
COMPILERNAME := $(firstword $(subst /, ,$(ROLLCOMPILER)))

ifndef ROLLMPI
  ROLLMPI = openmpi
endif

ifndef ROLLNETWORK
  ROLLNETWORK = eth
endif

NAME               = fftw_2.1.5_$(COMPILERNAME)_$(ROLLMPI)_$(ROLLNETWORK)
VERSION            = 2.1.5
RELEASE            = 6

SRC_SUBDIR         = fftw_2.1.5

SOURCE_NAME        = fftw
SOURCE_VERSION     = $(VERSION)
SOURCE_SUFFIX      = tar.gz
SOURCE_PKG         = $(SOURCE_NAME)-$(SOURCE_VERSION).$(SOURCE_SUFFIX)
SOURCE_DIR         = $(SOURCE_PKG:%.$(SOURCE_SUFFIX)=%)

TAR_GZ_PKGS        = $(SOURCE_PKG)
RPM.EXTRAS         = AutoReq:No
