PACKAGE     = fftw
CATEGORY    = applications

NAME        = sdsc-$(PACKAGE)-modules
RELEASE     = 12
PKGROOT     = /opt/modulefiles/$(CATEGORY)/$(PACKAGE)

VERSION_SRC = $(REDHAT.ROOT)/src/$(PACKAGE)/version.mk
VERSION_INC = version.inc
include $(VERSION_INC)

EXTRA_MODULE_VERSIONS = 2.1.5

RPM.EXTRAS  = AutoReq:No\nObsoletes:sdsc-fftw-modules_gnu,sdsc-fftw-modules_intel,sdsc-fftw-modules_pgi
RPM.PREFIX  = $(PKGROOT)
