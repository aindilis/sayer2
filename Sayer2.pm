package Sayer2;

# see Sayer;

use Manager::Dialog qw(Approve QueryUser);
use PerlLib::MySQL;
use PerlLib::Util;

# use Sayer2::CodeManager;
use Sayer2::DBDHash;

use Data::Dumper;
use Data::Dump::Streamer;

# use DB_File;
# use Tie::MLDBM;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / StorageFile CountData CountCode Debug IllGraph Graph Data Code
	IGraph IData ICode MyAnalyzer DBName Quiet IsCached /

  ];

sub init {
  my ($self, %args) = @_;
  $self->Debug($args{Debug} || 0);
  $self->Quiet($args{Quiet});
  $self->DBName($args{DBName} || "sayer2");
  $Sayer2::DBDHash::database = $self->DBName;
  $Sayer2::DBDHash::mysql = PerlLib::MySQL->new
    (
     DBName => $Sayer2::DBDHash::database,
    );

  my @items = qw(IllGraph Graph Data Code IGraph IData ICode);
  if (0) {
    # tie to files, this doesn't work very well
    foreach my $item (@items) {
      eval "tie my \%$item => 'DB_File', \"/var/lib/myfrdcsa/codebases/minor/sayer2/data/dbs/$item.db\", O_RDWR|O_CREAT, 0666;  \$self->$item(\\\%$item);";
    }
  } else {
    foreach my $item (@items) {
      eval "tie my \%$item, 'Sayer2::DBDHash', \"$item\", $args{Truncate}; \$self->$item(\\\%$item);";
    }
  }
  # retrieve the last value of countdata
  if (0) {
    my $maxdataid = 0;
    my $keys = [sort {$b <=> $a} keys %{$self->Data}];
    if (scalar @$keys) {
      $maxdataid = $keys->[0] + 1;
    }
    $self->CountData($maxdataid );

    # retrieve the last value of countcode
    $maxcodeid = 0;
    $keys = [sort {$b <=> $a} keys %{$self->Code}];
    if (scalar @$keys) {
      $maxcodeid = $keys->[0] + 1;
    }
    $self->CountCode($maxcodeid );
  } else {
    my $res1 = $Sayer2::DBDHash::mysql->Do
      (
       Statement => "select max(ID) from Data",
       Array => 1,
      );
    my $res2 = $Sayer2::DBDHash::mysql->Do
      (
       Statement => "select max(ID) from Code",
       Array => 1,
      );
    $self->CountData($res1->[0]->[0] + 1);
    $self->CountCode($res2->[0]->[0] + 1);
  }
}

sub Analyze {
  my ($self, %args) = @_;
  # based on what we know about this, perform various tests
  if (! defined $self->MyAnalyzer) {
    # use Sayer2::Analyzer;
    $self->MyAnalyzer
      (
       # Sayer2::Analyzer->new(),
      );
  }
  $self->MyAnalyzer->Analyze(%args);
}

sub GetCodeFromCodeRef {
  my $coderef = shift;
  my $thing = DeDumper(Dumper(Dump($coderef)));
  $thing =~ s/^\$CODE1 = //;
  return $thing;
}

# # Example

# my @result = $self->MySayer2->ExecuteCodeOnData
# 	(
# 	 Overwrite => $self->Overwrite,
# 	 CodeRef => $self->Codes->{ProcessTreebank},
# 	 Data => [{
# 		   Treebank => $treebankoutput,
# 		   OriginalSentence => $originalsentence,
# 		   Data => $args{Data},
# 		  }],
# 	);


# # What are all the attributes?

# Code
# CountCode
# CountData
# DBName
# Data
# Debug
# Graph
# ICode
# IData
# IGraph
# IllGraph
# IsCached
# MyAnalyzer
# Quiet
# StorageFile

# # What are all the flags?

# $args{CodeID}		
# $args{CodeRef}	
# $args{Code}		
# $args{DBName}		
# $args{DataID}		
# $args{Data}		
# $args{Debug}		
# $args{DoNotCache}	
# $args{GiveHasResult}	Like HasResult, determines if an existing result exists, but returns it if it does
# $args{HasResult}	Determines if an existing result exists, but does not return it
# $args{ID}		
# $args{MaxLength}	
# $args{NoRetrieve}	
# $args{OnlyRetrieve}	
# $args{Overwrite}	
# $args{Quiet}		
# $args{Result}		
# $args{Truncate}	


sub ExecuteCodeOnData {
  my ($self, %args) = @_;
  my $cref;
  my $code;
  my $codeid;
  if (exists $args{CodeRef}) {
    $cref = $args{CodeRef};
    $code = GetCodeFromCodeRef($cref);
    $codeid = $self->AddCode
      (Code => $code);
  } elsif (exists $args{Code}) {
    $code = $args{Code};
    $cref = eval $code;
    $codeid = $self->AddCode
      (Code => $code);
  } elsif (exists $args{CodeID}) {
    $codeid = $args{CodeID};
    $cref = $self->GetCodeFromID
      (CodeID => $codeid);
    $code = GetCodeFromCodeRef($cref);
  }

  # obtain data list
  my @dlist;
  my $dataid;
  if (exists $args{Data}) {
    $dataid = int($self->AddData(Data => $args{Data}));
    @dlist = @{$args{Data}};
  } elsif (exists $args{DataID}) {
    $dataid = int($args{DataID});
    @dlist = $self->GetDataFromID
      (DataID => $dataid);
  }

  # execute the code on the data
  # print "executing code $codeid on data $dataid and storing result\n";
  # check whether it doesn't already exist

  my $resultid;
  my @res;

  if (1) {
    # my $tmp1 = (exists $self->Graph->{$dataid}) ? 1 : 0;
    # my $tmp2 = (exists $self->Graph->{$dataid}->{$codeid}) ? 1 : 0;
    # print Dumper
    #   ({
    # 	DataID => $dataid,
    # 	CodeID => $codeid,
    # 	Tmp1 => $tmp1,
    # 	Tmp2 => $tmp2,
    # 	KeysData => [keys %{$self->Graph}],
    # 	KeysCode => [keys %{$self->Graph->{1}}],
    #    });
    print Dumper({
		  DataID => $dataid,
		  CodeID => $codeid,
		  Graph => $self->Graph,
		  }) if 0;
    my $dataandcodeidexist = (exists $self->Graph->{$dataid} and exists $self->Graph->{$dataid}->{$codeid}) ? 1 : 0;
    my $hasresult = exists $args{HasResult} ? 1 : 0;
    my $overwrite = (exists $args{Overwrite} and $args{Overwrite}) ? 1 : 0;
    my $result = (exists $args{Result}) ? 1 : 0;

    print Dumper({
		  DataAndCodeIDExist => $dataandcodeidexist,
		  HasResult => $hasresult,
		  Overwrite => $overwrite,
		  Result => $result,
		  GiveHasResult => $args{GiveHasResult},
		 }) if $self->Debug;

    # if there is a has result, we need to check whether the dataandcodeexist
    if ($hasresult) {
      return $dataandcodeidexist;
    }
    $self->IsCached($dataandcodeidexist);

    # if there is a result, we want to set the result
    if ($result) {
      print "Using provided result and adding to cache\n" unless $self->Quiet;
      if ($args{DoNotCache}) {
	print "Not caching as requested.\n" if $self->Debug;
      } else {
	$resultid = $self->AddData(Data => $args{Result});
	print Dumper({ResultID => $resultid});
	if (! defined $resultid) {
	  die "id not defined: ".Dumper(\@res)."\n\n";
	}
	# Assign($self->Graph,$dataid,$codeid,$resultid,$ts);
	# Assign($self->IGraph,$resultid,$codeid,$dataid,$ts);

	$self->DoAssign($dataid,$codeid,$resultid,$ts);
      }
      @res = @{$args{Result}};
      print Dumper(\@res);
      return @res;
    }

    # lastly, now we check if it is exists, and retrieve that, otherwise compute it, store it, and use that
    if ($dataandcodeidexist and ! $overwrite) {
      print "Retrieving result from cache\n" unless $self->Quiet;
      $resultid = $self->Graph->{$dataid}->{$codeid};
      print "hi\n" if $UNIVERSAL::debug;
      @res = $self->GetDataFromID(DataID => $resultid) if ! $args{NoRetrieve};
      print "ho\n" if $UNIVERSAL::debug;
      print Dumper({
		    Res => \@res,
		    GiveHasResult => $args{GiveHasResult},
		   }) if $self->Debug;
      # FIXME Does this next line handle NoRetrieve correctly?
      if ($args{GiveHasResult}) {
	return {Success => 1, Result => \@res};
      }
    } else {
      print "Computing result and adding to cache\n" unless ($self->Quiet or  $args{DoNotCache});
      if ($args{GiveHasResult}) {
	return {Success => 0};
      }
      @res = $cref->(@dlist);
      if ($args{DoNotCache}) {
	print "Not caching as requested.\n" if $self->Debug;
      } else {
	$resultid = $self->AddData(Data => \@res);
	if (! defined $resultid) {
	  die "id not defined: ".Dumper(\@res)."\n\n";
	}

	# Assign($self->Graph,$dataid,$codeid,$resultid,$ts);
	# Assign($self->IGraph,$resultid,$codeid,$dataid,$ts);

	$self->DoAssign($dataid,$codeid,$resultid,$ts);
      }
    }
    # print Dumper([$code,\@dlist,\@res]) if $self->Debug;
    print Dumper([$dataid,$codeid,$newcounter,$resultid,$code,\@res]) if $self->Debug;

    return @res;
  } else {
    if (exists $self->Graph->{$dataid} and exists $self->Graph->{$dataid}->{$codeid} and
	! (exists $args{Overwrite} and $args{Overwrite})) {
      if (exists $args{HasResult}) {
	return 1;
      }
      print "Retrieving result from cache\n";
      $resultid = $self->Graph->{$dataid}->{$codeid};
      @res = $self->GetDataFromID(DataID => $resultid) if ! $args{NoRetrieve};
    } else {
      if (exists $args{OnlyRetrieve}) {
	print "Skipping computing result because OnlyRetrieve has been set\n";
	return {Success => 0};
      }
      if (exists $args{HasResult}) {
	return 0;
      }
      print "Computing result and adding to cache\n";
      @res = $cref->(@dlist);
      $resultid = $self->AddData(Data => \@res);
      if (! defined $resultid) {
	die "id not defined: ".Dumper(\@res)."\n\n";
      }
      # now update the graph

      # for overwrites have to add something here to remove existing data


      # # $self->Graph->{$dataid}->{$codeid} = $resultid;
      # Assign($self->Graph,$dataid,$codeid,$resultid,$ts);

      # # $self->IGraph->{$resultid}->{$codeid} = $dataid;
      # Assign($self->IGraph,$resultid,$codeid,$dataid,$ts);

      $self->DoAssign($dataid,$codeid,$resultid,$ts);

      # # $self->IllGraph->{$data->{$dataid}}->{$code->{$codeid}} = $self->Data->{$resultid};
    }
    # print Dumper([$code,\@dlist,\@res]) if $self->Debug;
    print Dumper([$dataid,$codeid,$newcounter,$resultid,$code,\@res]) if $self->Debug;

    return @res;

  }
}

sub DoAssign {
  my ($self,$dataid,$codeid,$resultid,$ts) = @_;
  $newcounter = $self->Graph->{$dataid}->{$codeid}->{counter} + 1;
  Assign($self->Graph,$dataid,$codeid,'counter',$newcounter);
  Assign($self->Graph,$dataid,$codeid,$resultid,$newcounter,$ts);
  Assign($self->IGraph,$resultid,$codeid,$dataid,$newcounter,$ts);
  # print ($self->Graph->{$dataid}->{$codeid}->{counter} + 1)."\n";
}

sub Assign {
  my @items = @_;
  my $value = pop @items;
  my $tiedhash = shift @items;
  my $hashtobestored;
  if (exists $tiedhash->{$items[0]}) {
    $hashtobestored = $tiedhash->{$items[0]};
  } else {
    $hashtobestored = {};
  }
  # should generalize this to $hashtobestored->{$items[1]}->{$items[2]}->{$items[...]}->{$items[n]} = $value;
  my $size = scalar @items - 1;
  my $tobeevaled = "\$hashtobestored->".join("->",map {"{\$items[$_]}"} 1..$size)." = \$value";
  eval $tobeevaled;
  # $hashtobestored->{$items[1]} = $value;

  $tiedhash->{$items[0]} = $hashtobestored;
}

## Code functions

sub AddCode {
  my ($self, %args) = @_;
  my $code = $args{Code};
  if (! exists $self->ICode->{$code}) {
    my $codeid = $self->CountCode;
    $self->Code->{$codeid} = $code;
    $self->ICode->{$code} = $codeid;
    $self->CountCode($codeid + 1);
    return $codeid;
  } else {
    return $self->ICode->{$code};
  }
}

sub GetCodeID {
  my ($self, %args) = @_;
  my $tmp = $args{ID};
  if (exists $self->ICode->{$tmp}) {
    return $self->ICode->{$tmp};
  }
}

sub GetCodeFromID {
  my ($self, %args) = @_;
  my $c1 = $self->Code->{$args{CodeID}};
  my $cref = eval $c1;
  return $cref;
}

## Data functions

sub AddData {
  my ($self, %args) = @_;
  my $tmp = DumperIndent1($args{Data});
  if (! exists $self->IData->{$tmp}) {
    my $dataid = $self->CountData;
    $self->Data->{$dataid} = $tmp;
    $self->IData->{$tmp} = $dataid;
    $self->CountData($dataid + 1);
    return $dataid;
  } else {
    return $self->IData->{$tmp};
  }
}

# sub GetDataID {
#   my ($self, %args) = @_;
#   my $tmp = Dumper($args{ID});
#   if (exists $self->IData->{$tmp}) {
#     return $self->IData->{$tmp};
#   }
# }

sub GetDataFromID {
  my ($self, %args) = @_;

  # $newcounter = $self->Graph->{$dataid}->{$codeid}->{counter} + 1;
  # Assign($self->Graph,$dataid,$codeid,'counter',$newcounter);
  # Assign($self->Graph,$dataid,$codeid,$resultid,$newcounter,$ts);
  # Assign($self->IGraph,$resultid,$codeid,$dataid,$newcounter,$ts);

  my $d1 = $self->Data->{$args{DataID}};
  if (defined $d1) {
    $VAR1 = undef;
    eval $d1;
    eval $d1;
    my @dlist = @$VAR1;
    $VAR1 = undef;
    return @dlist;
  }
}

sub PrintAllInformation {
  my ($self, %args) = @_;
  $args{MaxLength} ||= 200;
  my $res = {};
  foreach my $attribute (qw(IllGraph Graph Data Code IGraph IData ICode)) {
    if ($attribute eq "IData") {
      my $idatatruncated = {};
      foreach my $key (keys %{$self->IData}) {
	my $key2 = substr($key,0,$args{MaxLength});
	$idatatruncated->{$key2} = $self->IData->{$key};
      }
      $res->{IData} = $idatatruncated;
    } elsif ($attribute eq "Data") {
      my $datatruncated = {};
      foreach my $key (keys %{$self->Data}) {
	$datatruncated->{$key} = substr($self->Data->{$key},0,$args{MaxLength});
      }
      $res->{Data} = $datatruncated;
    } else {
      $res->{$attribute} = $self->$attribute;
    }
  }
  if (! $args{Silent}) {
    print "\n\n\n\n\n\n\n\n\n\n\n\n";
    $self->PrintOutTraces();
  }
  return $res;
}

sub PrintOutTraces {
  my ($self, %args) = @_;
  foreach my $key1 (sort {$a <=> $b} keys %{$self->Graph}) {
    my $data = eval ($self->Data->{"$key1"} || $self->Data->{int($key1)});
    foreach my $key2 (sort {$a <=> $b} keys %{$self->Graph->{$key1}}) {
      my $code = eval ($self->Code->{"$key2"} || $self->Code->{int($key2)});
      foreach my $key3 (sort {$a <=> $b} keys %{$self->Graph->{$key1}->{$key2}}) {
	my $result = eval ($self->Data->{"$key3"} || $self->Data->{int($key3)});
	next if $key3 eq 'counter';
	print "data $key1\n";
	print "code $key2\n";
	print "result $key3\n";

	print Dumper([
		      $code,
		      $data->[0],
		      $result->[0],
		     ]);
	print '['.join(',',sort {$a <=> $b} keys %{$self->Graph->{$key1}->{$key2}->{$key3}})."]\n";
	print "\n\n\n\n\n\n";
      }
    }
  }
}

sub ClearCache {
  my ($self, %args) = @_;
  if (Approve("Clear the cache for DB <db>?")) {
    foreach my $table (qw(Code Data Graph ICode IData IGraph IllGraph)) {
      $Sayer2::DBDHash::mysql->Do(Statement => "truncate $table;");
    }
  }
}

1;
