package Sayer2::DBDHash;

use PerlLib::Util;

use Data::Dumper;
use DBI;

my $debug = 0;

sub TIEHASH {
  my ($class,@args) = @_;
  my $table = shift @args;
  my $truncate = shift @args;

  if ($truncate) {
    $mysql->DBH->do("truncate table $table");
  }
  my %self = (_Table => $table);
  # print Dumper(\%self);
  # make sure the "$table" table exists
  if (! ExistsTable($table)) {
    CreateTable($table);
  }
  bless \%self,$class;
}

sub ExistsTable {
  my ($table) = @_;
  my $statement1 = "show TABLES from $database LIKE '$table'";
  my $res1 = $mysql->Do
    (
     Statement => $statement1,
     Array => 1,
    );
  return ! ! scalar @$res1;
}

sub CreateTable {
  my ($table) = @_;
  my $sql = <<EOF;
CREATE TABLE `<TABLE>` (
  `ID` int(15) NOT NULL auto_increment,
  `MyKey` longtext,
  `Value` longtext,
  PRIMARY KEY  (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;
EOF
  $sql =~ s/<TABLE>/$table/gs;
  $mysql->DBH->do($sql);
}

sub DESTROY {
  my ($inst) = @_;
}

sub STORE {
  my ($self,$key,$value) = @_;
  print "STORE\n" if $debug;

  my $table = $self->{_Table};
  my $quotedkey = $mysql->Quote(Dumper($key));
  my $quotedvalue = $mysql->Quote(Dumper($value));

  my $statement1 = "delete from $table where MyKey=$quotedkey";
  my $res1 = $mysql->Do
    (
     Statement => $statement1,
    );

  # ignore this for now, try to add it
  my $statement2 = "insert into $table values (NULL, $quotedkey,$quotedvalue)";
  my $res2 = $mysql->Do
    (
     Statement => $statement2,
    );
}

sub FETCH {
  my ($self,$key) = @_;
  print "FETCH\n" if $debug;
  my $table = $self->{_Table};
  my $quotedkey = $mysql->Quote(Dumper($key));
  my $statement1 = "select * from $table where MyKey=$quotedkey";
  my $res1 = $mysql->Do
    (
     Statement => $statement1,
    );
  if (scalar keys %$res1) {
    return DeDumper($res1->{[keys %$res1]->[0]}->{Value});
  }
}

# Following methods remain to be implemented!

sub EXISTS {
  my ($self,$key) = @_;
  print "EXISTS\n" if $debug;

  my $table = $self->{_Table};
  my $quotedkey = $mysql->Quote(Dumper($key));
  my $statement1 = "select * from $table where MyKey=$quotedkey";
  my $res1 = $mysql->Do
    (
     Statement => $statement1,
    );
  return ! ! scalar keys %$res1;
}

sub DELETE {
  my ($self,$key) = @_;
  print "DELETE\n" if $debug;

  my $table = $self->{_Table};
  my $quotedkey = $mysql->Quote(Dumper($key));
  my $statement1 = "delete from $table where MyKey=$quotedkey";
  my $res1 = $mysql->Do
    (
     Statement => $statement1,
    );
}

sub CLEAR {
  my ($self) = @_;
  print "CLEAR\n" if $debug;

  my $table = $self->{_Table};
  my $statement1 = "delete from $table";
  my $res1 = $mysql->Do
    (
     Statement => $statement1,
    );
}

# for (key = firstkey(); key.dptr != NULL; key = nextkey(key))

sub FIRSTKEY {
  my ($self) = @_;
  print "FIRSTKEY\n" if $debug;
  $self->{_CurrentKey} = -1;
  return $self->NEXTKEY;
}

sub NEXTKEY {
  my ($self) = @_;
  print "NEXTKEY\n" if $debug;

  my $table = $self->{_Table};
  my $statement1 = "select min(ID) from $table where ID > ".$self->{_CurrentKey};
  my $res1 = $mysql->Do
    (
     Statement => $statement1,
     Array => 1,
    );
  my $id = $res1->[0]->[0];
  if (defined $id) {
    $self->{_CurrentKey} = $id;
    my $statement2 = "select MyKey from $table where ID = $id";
    my $res2 = $mysql->Do
      (
       Statement => $statement2,
       Array => 1,
      );

    if (scalar @$res2) {
      return DeDumper($res2->[0]->[0]);
    }
  }
  return undef;
}

1;
