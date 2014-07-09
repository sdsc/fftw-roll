ifndef ROLLCOMPILER
  COMPILERNAME = gnu
endif
COMPILERNAME := $(firstword $(subst /, ,$(ROLLCOMPILER)))

NAME    = fftw_2.1.5-modules_$(COMPILERNAME)
VERSION = 2.1.5
RELEASE = 5
RPM.EXTRAS         = AutoReq:No
