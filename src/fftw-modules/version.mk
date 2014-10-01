ifndef ROLLCOMPILER
  COMPILERNAME = gnu
endif
COMPILERNAME := $(firstword $(subst /, ,$(ROLLCOMPILER)))

PACKAGE     = fftw
CATEGORY    = applications

NAME        = $(PACKAGE)-modules_$(COMPILERNAME)
RELEASE     = 8
PKGROOT     = /opt/modulefiles/$(CATEGORY)/.$(COMPILERNAME)/$(PACKAGE)

VERSION_SRC = $(REDHAT.ROOT)/src/$(PACKAGE)/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

VERSION_ADD = 2.1.5

RPM.EXTRAS  = AutoReq:No
