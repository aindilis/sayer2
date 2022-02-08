sub MakeStatements {
  # functions
  # just use a few functions for now to test it out

  my @functions =
    (
     # 'sub {print Dumper($_[0])}',
     'sub {split / /, $_[0]}',
     'sub {substr $_[0], 0, 10}',
     'sub {uc $_[0]}',
     'sub {lc $_[0]}',
    );

  foreach my $function (@functions) {
    $self->Sayer2->AddCode(Function => $function);
  }
}


sub ConstructGraph {
  # now, go about constructing a graph from this
  # for now, just iterate over everything, a few layers deep
  my $finished;
  while (! $finished) {
    $finished = 1;
    foreach my $dataid (keys %{$self->Data}) {
      # eval each function on each data point and add to the graph
      foreach my $codeid (keys %{$self->Code}) {
	# we want to call a function here

      }
    }
  }
}

