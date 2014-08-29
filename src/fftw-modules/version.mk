ifndef ROLLCOMPILER
  COMPILERNAME = gnu
endif
COMPILERNAME := $(firstword $(subst /, ,$(ROLLCOMPILER)))

NAME       = fftw-modules_$(COMPILERNAME)
VERSION    = 3.3.3
RELEASE    = 5

RPM.EXTRAS = AutoReq:No
