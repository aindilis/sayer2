#!/usr/bin/env perl

use BOSS::Config;
use Sayer2;

use Data::Dumper;

$specification = q(
	-t		Truncate the databases
	-q		Quit after truncating
  );

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
$UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/sayer2";

my $sayer2 = Sayer2->new
  (
   DBName => 'sayer2_test',
   Truncate => exists $conf->{'-t'},
  );

die "Truncated, quitting\n" if exists $conf->{'-q'};

$sayer2->PrintAllInformation();
