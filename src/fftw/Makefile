# $Id$
#
# @Copyright@
#
# 				Rocks(r)
# 		         www.rocksclusters.org
# 		         version 7.0 (Manzinita)
#
# Copyright (c) 2000 - 2017 The Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice unmodified and in its entirety, this list of conditions and the
# following disclaimer in the documentation and/or other materials provided
# with the distribution.
#
# 3. All advertising and press materials, printed or electronic, mentioning
# features or use of this software must display the following acknowledgement:
#
# 	"This product includes software developed by the Rocks(r)
# 	Cluster Group at the San Diego Supercomputer Center at the
# 	University of California, San Diego and its contributors."
#
# 4. Except as permitted for the purposes of acknowledgment in paragraph 3,
# neither the name or logo of this software nor the names of its
# authors may be used to endorse or promote products derived from this
# software without specific prior written permission.  The name of the
# software includes the following terms, and any derivatives thereof:
# "Rocks", "Rocks Clusters", and "Avalanche Installer".  For licensing of
# the associated name, interested parties should contact Technology
# Transfer & Intellectual Property Services, University of California,
# San Diego, 9500 Gilman Drive, Mail Code 0910, La Jolla, CA 92093-0910,
# Ph: (858) 534-5815, FAX: (858) 534-7345, E-MAIL:invent@ucsd.edu
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS''
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# @Copyright@
#
# $Log$

REDHAT.ROOT = $(CURDIR)/../../

-include $(ROCKSROOT)/etc/Rules.mk
include Rules.mk
include $(SDSCDEVEL)/Pull.mk
include $(SDSCDEVEL)/Rules.mk

COMPILE_FLAGS = -O2 -fPIC
CONFIG_OPTIONS = --enable-openmp --enable-mpi --enable-threads --enable-shared
ifeq ("$(COMPILERNAME)", "intel")
  COMPILE_FLAGS = -O3 -fp-model precise -prec_div -prec_sqrt -ftz -fPIC
else ifeq ("$(COMPILERNAME)", "pgi")
  COMPILE_FLAGS = -fast -fpic -Mflushz -Mdaz -Kieee -Mlarge_arrays -fPIC
endif

ifneq ("$(COMPILERNAME)","pgi")
 ifneq ("$(ROLLOPTS)", "$(subst avx2,,$(ROLLOPTS))")
    CONFIG_OPTIONS += --enable-avx2
 else ifneq ("$(ROLLOPTS)", "$(subst avx,,$(ROLLOPTS))")
    CONFIG_OPTIONS += --enable-avx
 endif
endif

$(NAME).spec: DESCRIPTION LICENSE

DESCRIPTION:
	$(MODULE_LOAD_CC); \
	( \
	  $(DESCRIBE_PKG); \
	  $(DESCRIBE_CC); \
	  $(DESCRIBE_MPI) \
	) > $@

LICENSE: $(SRC_DIRS)
	$(CHECK_LICENSE_FILES)
	echo GPLv2+ > $@

build: $(SRC_DIRS)
	@echo "::: Package $(NAME) build complete :::"

install::
	( \
	  $(MODULE_LOAD_CC); \
	  $(MODULE_LOAD_MPI); \
	  export CC=$(CC); \
	  export CFLAGS="$(COMPILE_FLAGS)"; \
	  export F77=$(FC); \
	  export FFLAGS="$(COMPILE_FLAGS)"; \
	  cd $(SOURCE_DIR); \
	  ./configure --host `bash config.guess` F77=$(FC) CC=$(CC) MPICC=mpicc \
	              --prefix=$(PKGROOT) $(CONFIG_OPTIONS);  \
	  $(MAKE); \
	  $(MAKE) prefix=$(ROOT)/$(PKGROOT) install; \
	  $(MAKE) distclean; \
	  ./configure --host `bash config.guess` F77=$(FC) CC=$(CC) MPICC=mpicc \
	       --enable-single --prefix=$(PKGROOT) $(CONFIG_OPTIONS);  \
	  $(MAKE); \
	  $(MAKE) prefix=$(ROOT)/$(PKGROOT) install;  \
	)
	$(INSTALL_LICENSE_FILES)
	@echo "::: Package $(NAME) install complete :::"

clean::
	rm -rf $(SOURCE_DIR) DESCRIPTION LICENSE
