package Sayer2::Tie;
use DBI;

# This is a tie class showing how a hash can be mapped onto a table in a
# database supported via the DBI module.  Under development - course
# exercise is to test and complete the class

sub TIEHASH {
        my ($class,$hashref) = @_;
        my %hint;
	my $passwd = `cat /etc/myfrdcsa/config/perllib`;
	chomp $password;
        %hint = (type => "mysql",
                host => "localhost",
                port => 3306,
                user => "root",
                pass => $password,
                database => "sayer2",
                table => "data",
                keyfield => "key",
                valfield => "value",
                %$hashref);
        $hint{"_dbh"} = DBI -> connect("DBI:$hint{type}:$hint{database}:$hint{host}:$hint{port}",
                $hint{user},$hint{pass}, {RaiseError => 1})
                or die ("connection: $DBI::errstr\n");
        bless \%hint,$class;
        }

sub DESTROY {
        my ($inst) = @_;
        }

sub STORE {
        my ($hint,$key,$value) = @_;
# At present, causes duplicate keys ... need to modify this behaviour
$statement =
"INSERT INTO $$hint{table} ($$hint{keyfield}, $$hint{valfield}) VALUES( \"$key\", \"$value\" )";
$$hint{"_dbh"} -> do($statement);
        }

sub FETCH {
        my ($hint,$key) = @_;
	$statement =
"SELECT $$hint{keyfield}, $$hint{valfield} FROM $$hint{table} where $$hint{keyfield} = \"$key\"";

$getkey = $$hint{"_dbh"} -> prepare($statement);
$getkey -> execute;
@row = $getkey->fetchrow;
        return $row[1];
        }

# Following methods remain to be implemented!

sub EXISTS {
        my ($inst,$key) = @_;
        return (exists $inst->{$key});
        }

sub DELETE {
        my ($inst,$key) = @_;
        return (delete $inst->{$key});
        }

sub CLEAR {
        my ($inst) = \{$_[0]};
        my %freshen;
        $inst = \%freshen;
        }

sub FIRSTKEY {
        my ($inst) = @_;
        my $temp = keys %{$inst};
        return scalar each %{$inst};
        }

sub NEXTKEY {
        my ($inst) = @_;
        return scalar each %{$inst};
        }

1;
