#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use Test::More tests => 12;

use_ok('Data::Dumper');
use_ok('FileHandle');
use_ok('Sayer2');

my $testharness = Sayer2->new(DBName => 'sayer2_test');
isa_ok( $testharness, 'Sayer2' );


foreach my $contents (qw(Test1 Test2 Test3)) {
  $testharness->ExecuteCodeOnData
    (
     Test => 1,
    );
   is( $res->{Contents}, $contents, "The contents returned are correct." );
}

$testharness->StopTemporaryUniLangInstance;

1;
