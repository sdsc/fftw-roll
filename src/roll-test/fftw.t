#!/usr/bin/perl -w
# fftw roll installation test.  Usage:
# fftw.t [nodetype]
#   where nodetype is one of "Compute", "Dbnode", "Frontend" or "Login"
#   if not specified, the test assumes either Compute or Frontend

use Test::More qw(no_plan);

my $appliance = $#ARGV >= 0 ? $ARGV[0] :
                -d '/export/rocks/install' ? 'Frontend' : 'Compute';
my $installedOnAppliancesPattern = '.';
my $output;

my $TESTFILE = 'rollfftw';

my @COMPILERS = split(/\s+/, 'ROLLCOMPILER');
my @NETWORKS = split(/\s+/, 'ROLLNETWORK');
my @MPIS = split(/\s+/, 'ROLLMPI');
my %CC = ('gnu' => 'gcc', 'intel' => 'icc', 'pgi' => 'pgcc');

open(OUT, ">$TESTFILE.c");
print OUT <<END;
#ifdef FFTW3
#include <fftw3.h>
#define c_re(X) X[0]
#define c_im(X) X[1]
#else
#include <fftw.h>
#endif
#include <stdio.h>

#define N 4

int main(int argc, char **argv) {
  fftw_complex *in, *out;
  fftw_plan p;
  int i;

  in = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);
  out = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * N);

  for(i = 0; i < N; i++) {
    c_re(in[i]) = i;
    c_im(in[i]) = 0.0;
  }

#ifdef FFTW3
  p = fftw_plan_dft_1d(N, in, out, FFTW_FORWARD, FFTW_ESTIMATE);
  fftw_execute(p);
#else
  p = fftw_create_plan(N, FFTW_FORWARD, FFTW_ESTIMATE);
  fftw(p, 1, in, 1, 0, out, 1, 0);
#endif

  fprintf(stdout, "{");
  for(i = 0 ; i < N; i++) {
    fprintf(stdout, " {%2.2f, %2.2f}", c_re(out[i]), c_im(out[i]));
  }
  fprintf(stdout, " }\\n");

  fftw_destroy_plan(p);
  fftw_free(in); fftw_free(out);
}
END

# fftw-common.xml
$output = `find /opt/fftw -name bin | grep -vs 2.1.5`;
foreach my $compiler (@COMPILERS) {
  my $compilername = (split('/', $compiler))[0];
  foreach my $mpi (@MPIS) {
    if($appliance =~ /$installedOnAppliancesPattern/) {
      like($output, qr#$compilername/$mpi#,
           "fftw latest/$compilername/$mpi installed");
    } else {
      unlike($output, qr#$compilername/$mpi#,
             "fftw latest/$compilername/name$mpi not installed");
    }
  }
}
$output = `find /opt/fftw/2.1.5 -name fftw.h`;
foreach my $compiler (@COMPILERS) {
  my $compilername = (split('/', $compiler))[0];
  foreach my $mpi (@MPIS) {
    if($appliance =~ /$installedOnAppliancesPattern/) {
      like($output, qr#$compilername/$mpi#,
           "fftw v2.1.5/$compilername/$mpi installed");
    } else {
      unlike($output, qr#$compilername/$mpi#,
             "fftw v2.1.5/$compilername/$mpi not installed");
    }
  }
}

SKIP: {

  skip 'modules not installed', 1 if ! -f '/etc/profile.d/modules.sh';

  foreach my $compiler (@COMPILERS) {
    my $compilername = (split('/', $compiler))[0];
    SKIP : {
      $output = `find /opt/fftw -name include | grep -vs 2.1.5`;
      skip "fftw latest/$compilername not installed", 3
        if $output !~ m#/$compilername/#;
      ok(-l "/opt/modulefiles/applications/.$compilername/fftw/.version",
         "module file for fftw/latest/$compilername installed");
      foreach my $mpi (@MPIS) {
        foreach my $network (@NETWORKS) {
          $output = `. /etc/profile.d/modules.sh; module load $compiler ${mpi}_$network fftw; $CC{$compilername} -DFFTW3 -I\$FFTWHOME/include -L\$FFTWHOME/lib -o $TESTFILE.$compilername.exe $TESTFILE.c -lfftw3 -lm`;
          ok(-f "$TESTFILE.$compilername.exe",
             "compile/link using fftw/latest/$compilername/$mpi");
          $output = `. /etc/profile.d/modules.sh; module load $compiler ${mpi}_$network fftw;./$TESTFILE.$compilername.exe`;
          like($output, qr/{ {6.00, 0.00} {-2.00, 2.00} {-2.00, 0.00} {-2.00, -2.00} }/, "run using fftw/latest/$compilername/$mpi");
        }
      }
    }
  }

  foreach my $compiler (@COMPILERS) {
    my $compilername = (split('/', $compiler))[0];
    SKIP: {
      $output = `find /opt/fftw -name include | grep 2.1.5`;
      skip "fftw 2.1.5/$compilername not installed", 3
        if $output !~ m#/$compilername/#;
      ok(-f "/opt/modulefiles/applications/.$compilername/fftw/2.1.5",
         "module file for fftw/2.1.5/$compilername installed");
      foreach my $mpi (@MPIS) {
        foreach my $network (@NETWORKS) {
          $output = `. /etc/profile.d/modules.sh; module load $compiler ${mpi}_$network fftw/2.1.5; $CC{$compilername} -I\$FFTWHOME/include -L\$FFTWHOME/lib -o $TESTFILE.$compilername.$mpi.exe $TESTFILE.c -lfftw -lm`;
          ok(-f "$TESTFILE.$compilername.$mpi.exe",
             "compile/link using fftw/2.1.5/$compilername/$mpi");
          $output = `. /etc/profile.d/modules.sh; module load $compiler ${mpi}_$network fftw;./$TESTFILE.$compilername.exe`;
          like($output, qr/{ {6.00, 0.00} {-2.00, 2.00} {-2.00, 0.00} {-2.00, -2.00} }/,
               "run using fftw/2.1.5/$compilername/$mpi");
        }
      }
    }
  }

}

# fftw-doc.xml
SKIP: {
  skip 'not server', 1 if $appliance ne 'Frontend';
  ok(-d '/var/www/html/roll-documentation/fftw', 'doc installed');
}

`rm -f $TESTFILE*`;
