package Sayer2::Multiple;

# (note that I have some ideas for how to get sayer to work with
#  this correctly.  Basically, we can use a compression table over
#  data entries, and have sayer entries consisting of data, usually
#  deeply dumped perl data structures, and pointers to existing
#  versions of subcomponents.  Or we could use Dumpers existing
#  indexing mechanism and link them to existing entries as needed.
#  Then, what we do is to take an md5 sum of the given item, or its
#  length or other derivable properties, expressed via a function
#  application, as in "(equal (md5 item) 'klefkjfds')" 
#  (or whatever perl equivalent would be), and use that to index
#  the items.  Then we can assert things about the data stored in
#  the system, such as that we've seen it repeatedly for a given
#  function invocation.  Basically I have to rewrite sayer here, so
#  that it works well with this notion of using multiple data
#  points per function.  We should be even to watch data flowing
#  through programs as a result.  Compress the data that we record.
#  Prove things about it.)

use Sayer2;

use Moose;

has 'Debug' => (is => 'rw', isa => 'Bool');

has 'Sayer2' =>
  (
   is => 'rw',
   isa => 'Sayer2',
   handles => {
	       Analyze => 1,
	       GetCodeFromCodeRef => 1,
	       ExecuteCodeOnData => 1,
	       Assign => 1,
	       AddCode => 1,
	       GetCodeID => 1,
	       GetCodeFromID => 1,
	       AddData => 1,
	       GetDataFromID => 1,
	       PrintAllInformation => 1,
	       ClearCache => 1,
	      },
  );

sub BUILD {
  my ($self,%args) = (shift,%{$_[0]});
  $self->Sayer2
    (Sayer2->new(DBName => $args{DBName}));
}

sub RecordCall {
  my ($self,%args) = @_;
  print Dumper
    ({
      Function => 'RecordCall',
      Args => \%args,
     });
  #   # look into the sayer cache to see if we get the
  #   # expected result for this data point

  #   # does the data point exist in the cache

  #   # if it isn't the same, mark the function as being
  #   # nondeterministic
}

sub Test {
  my (%args) = @_;
  print Dumper
    ({
      Function => 'Test',
      Args => \%args,
     });
  #   # look into the sayer cache to see if we get the
  #   # expected result for this data point

  #   # does the data point exist in the cache

  # }
}

sub RecordResult {
  my (%args) = @_;
  print Dumper
    ({
      Function => 'RecordResult',
      Args => \%args,
     });

}

sub Compare {
  my (%args) = @_;
  print Dumper
    ({
      Function => 'Compare',
      Args => \%args,
     });

}

1;
