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

#ifdef FFTW_SINGLE
int main(int argc, char **argv) {
  fftwf_complex *in, *out;
  fftwf_plan p;
  int i;

  in = (fftwf_complex*) fftwf_malloc(sizeof(fftwf_complex) * N);
  out = (fftwf_complex*) fftwf_malloc(sizeof(fftwf_complex) * N);

  for(i = 0; i < N; i++) {
    c_re(in[i]) = i;
    c_im(in[i]) = 0.0;
  }

#ifdef FFTW3
  p = fftwf_plan_dft_1d(N, in, out, FFTW_FORWARD, FFTW_ESTIMATE);
  fftwf_execute(p);
#else
  p = fftwf_create_plan(N, FFTW_FORWARD, FFTW_ESTIMATE);
  fftwf(p, 1, in, 1, 0, out, 1, 0);
#endif

  fprintf(stdout, "{");
  for(i = 0 ; i < N; i++) {
    fprintf(stdout, " {%2.2f, %2.2f}", c_re(out[i]), c_im(out[i]));
  }
  fprintf(stdout, " }\\n");

  fftwf_destroy_plan(p);
  fftwf_free(in); fftwf_free(out);
}
#else
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
#endif
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

foreach my $compiler (@COMPILERS) {
  my $compilername = (split('/', $compiler))[0];
  foreach my $mpi (@MPIS) {
    $output = `module load $compiler $mpi fftw; $CC{$compilername} -DFFTW3 -I\$FFTWHOME/include -L\$FFTWHOME/lib -o $TESTFILE.$compilername.exe $TESTFILE.c -lfftw3 -lm`;
    ok(-f "$TESTFILE.$compilername.exe",
       "compile/link using fftw/latest/$compilername/$mpi");
    $output = `module load $compiler $mpi fftw;./$TESTFILE.$compilername.exe`;
    like($output, qr/{ {6.00, 0.00} {-2.00, 2.00} {-2.00, 0.00} {-2.00, -2.00} }/, "run using fftw/latest/$compilername/$mpi double precision");

    $output = `module load $compiler $mpi fftw; $CC{$compilername} -DFFTW3 -DFFTW_SINGLE -I\$FFTWHOME/include -L\$FFTWHOME/lib -o $TESTFILE.$compilername.exe $TESTFILE.c -lfftw3f -lm`;
    ok(-f "$TESTFILE.$compilername.exe",
       "compile/link using fftw/latest/$compilername/$mpi");
    $output = `module load $compiler $mpi fftw;./$TESTFILE.$compilername.exe`;
    like($output, qr/{ {6.00, 0.00} {-2.00, 2.00} {-2.00, 0.00} {-2.00, -2.00} }/, "run using fftw/latest/$compilername/$mpi single precision");

  }
  $output = `module load $compiler fftw; echo \$FFTWHOME 2>&1`;
  my $firstmpi = $MPIS[0];
  $firstmpi =~ s#/.*##;
  like($output, qr#/opt/fftw/.*/$compiler/$firstmpi#, 'fftw modulefile defaults to first mpi');
}

foreach my $compiler (@COMPILERS) {
  my $compilername = (split('/', $compiler))[0];
  foreach my $mpi (@MPIS) {
    $output = `module load $compiler $mpi fftw/2.1.5; $CC{$compilername} -I\$FFTWHOME/include -L\$FFTWHOME/lib -o $TESTFILE.$compilername.$mpi.exe $TESTFILE.c -lfftw -lm`;
    ok(-f "$TESTFILE.$compilername.$mpi.exe",
       "compile/link using fftw/2.1.5/$compilername/$mpi");
    $output = `module load $compiler $mpi fftw;./$TESTFILE.$compilername.exe`;
    like($output, qr/{ {6.00, 0.00} {-2.00, 2.00} {-2.00, 0.00} {-2.00, -2.00} }/,
         "run using fftw/2.1.5/$compilername/$mpi");
  }
}

`/bin/ls /opt/modulefiles/applications/fftw/[3-9]* 2>&1`;
ok($? == 0, "fftw/latest module installed");
`/bin/ls /opt/modulefiles/applications/fftw/.version.[3-9]* 2>&1`;
ok($? == 0, "fftw/latest version module installed");
ok(-l "/opt/modulefiles/applications/fftw/.version",
   "fftw version module link created");
`/bin/ls /opt/modulefiles/applications/fftw/2.1.5 2>&1`;
ok($? == 0, "fftw/2.1.5 module installed");
`/bin/ls /opt/modulefiles/applications/fftw/.version.2.1.5 2>&1`;
ok($? == 0, "fftw/2.1.5 version module installed");

`rm -f $TESTFILE*`;
