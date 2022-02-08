package Sayer2::Profiler;

# do timing of functions and store them correctly, along with other
# metadata about the running environment of the system, so as to be
# able to handle different computers and Virtual Machines, etc., size
# of input, etc.  Do not store results for very frequently called
# functions, any more than is needed, etc.  This information is needed
# for the web services

# should keep a record of the state of the service, because execution
# times will vary based on the status of the service, etc, the system
# load, and so forth.  So as much as possible, track that kind of
# information.

use Data::Dumper;

sub Profile {
  my ($self,@args) = @_;

}

1;
