#!/usr/bin/perl -w

# use System::Assert;
use BOSS::Config;
use Capability::NER;
use Corpus::Sources;
use Lingua::EN::Extract::Dates;
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

my $sayer = Sayer2->new
  (
   DBName => 'sayer2_test',
   Truncate => exists $conf->{'-t'},
  );

die "Truncated, quitting\n" if exists $conf->{'-q'};

$UNIVERSAL::ne = Capability::NER->new
  (EngineName => "Stanford");
$UNIVERSAL::de = Lingua::EN::Extract::Dates->new;

my $mysql = PerlLib::MySQL->new
  (DBName => "unilang");

my $res = $mysql->Do
  (
   Statement => "select Contents from messages where Sender='UniLang-Client' and Contents != 'Register' and length(Contents) < 200 limit 100",
   Array => 1,
  );

foreach my $entry (@$res) {
  print Dumper($entry);
  my $copy1 = $entry->[0];
  my $copy2 = $entry->[0];
  $sayer->ExecuteCodeOnData
    (
     Code => 'sub {$_[0] =~ s/\s//sg; $_[0]}',
     Data => [$copy1],
     Overwrite => 1,
    );
  $sayer->ExecuteCodeOnData
    (
     Code => 'sub {$_[0] =~ s/\s//sg; $_[0]}',
     Data => [$copy2],
     Overwrite => 1,
    );
  # $sayer->ExecuteCodeOnData
  #   (
  #    Code => 'sub {$UNIVERSAL::de->TimeRecognizeText(Date => $_[0]->[3],Text => $_[0]->[4],);}',
  #    Data => [$entry],
  #   );
}

print Dumper($sayer);

# okay we want to run a particular function on a bunch of data

# just do something simple for starters


# we want to be able to call TimeX, NER, Assert, etc. on a few unilang
# entries.  Let's do this thing.

# maybe we can even use the "memoize" style format where it
# automatically tracks function calls.

# for now just do it manually

# note that eventually we can have things like "assert" "isa" $dataref
# "such and such", because we can simply have a mapping between
# assertions and code refs.  So that we can use FreeKBS as a reasoning
# base here.  or maybe have a module so these things can be queried
# from within FreeKBS
