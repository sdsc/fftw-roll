ifndef ROLLCOMPILER
  COMPILERNAME = gnu
endif
COMPILERNAME := $(firstword $(subst /, ,$(ROLLCOMPILER)))

NAME        = fftw-modules_$(COMPILERNAME)
RELEASE     = 7
PKGROOT     = /opt/modulefiles/applications/.$(COMPILERNAME)/fftw

VERSION_SRC = $(REDHAT.ROOT)/src/fftw/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

VERSION_ADD = 2.1.5

RPM.EXTRAS  = AutoReq:No
