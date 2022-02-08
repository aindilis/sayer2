(for starters, don't do anything fancy, just get it to work with
 multiple results, i.e. result->{code}->{data} = [res1,res2,res3]
 (Don't know how this should work using tied hashes))

(ensure we use compact, no random ordering of hashes,
 Data::Dumper, note the one with spaces and returns)

(We want to record the time of assertions into the KB, record
 each assertion as a distinct event, maybe also the time of
 retrievals)

(so what are the use cases.
 (record the args and other metadata of a function call)
 (record the result of the function call)
 (record a function definition, and computational context)

 (compare different recorded invocations
  (determine if function is nondeterministic)
  (static analysis of the function)
  (dynamic analysis of the function)
  (create a KB about the function)
  (distinguish invocations of the function based on the actual code of the function at the time)
  (cryptosign the functions)
  
  )
 )

(break the function call args into different pieces - look into
 data dumper algorithm for doing relative links within a data
 structure)

(store in a text repository)

(keep lisp like functional descriptions of data, like as in NLU
 annotations, i.e. (substr (entry-fn sayer2 11353232) 0 25))

(try to compute relatively minimal expressions to describe
values.  For instance, if there are two strings in the KB, one $a
= "DFKSJLJDF...", and another $b = "DFKSJ", you could represent b with 
(substr a 0 5) in the KB.  Compute minimal expressions.  This is
going to be the theorem proving that goes on in sayer.
I.e. functions that compute values in the base.  The functions
require their definitions.  So use the indexed functions that are
known to be determinimistic to do this.  Need processes which try
to notice things about data.  This is the iaec and
interestingness criteria.

Use the evolutionary programming, or how do we compute these
things?

(compute succient descriptions of text - this is compression -
 functional compression? - most eloquent description is
 undecidable in general.)

(have functions describe not only "text" but also arbitrary data
 structures and code.)

(do we use heuristics?)

(could do things in lisp with something like v2357095723875 to
 denote a variable containing the value of object represented by
 ID 2357095723875, maybe we could use "(v2357095723875)"
 or "(eval v2357095723875)" a function which is defined which
 executes and returns the value, the definition of the function
 would be the representation we are looking for.  Keep in mind we
 need load appropriate definitions as needed when evaling.  maybe
 a planner could be used.)

(We really want a master control program type thing to index all
 functions. problem becomes how to represent them that have
 complex dependencies, like as in object oriented code.)

(solution (maybe could have initialization and destruction
 functions, like for instance, launching unilang as needed for
 agent code to execute.  execution preconditions.  think vagrant
 and VMs.)
 (In CLOS these are done with before, after, and around auxillary
 functions.))

(have file system be part of the representation - hence KBFS)

(when evaling, use prepost to check for cached values for
 deterministic functions)

(side effects is learning APIs (note learning APIs is learning
protocols as in "Art of the Metaobject Protocol"))

(since code is data in lisp, we can represent arbitrary code
 using the data, hence, program equivalence)

(need to account for timing of function runs - precise profiling
 and complexity info added into the function KB)

(kind of like an FRDCSA of functions)

(use vagrant to model context, skip it if equivalent setup at the
 ready)

(integrate with auto programmer)

)

(setup equations such as f(x1,x2,...,xn) = y, and solve for the
 inputs required to generate y, where y is some data structure.
 Do this also where y is a data structure representing a
 function, etc.)

(possibly use git to store function and dependendent functions'
 definitions)

(just realized that almost always the most elegant description
 will be something like v1093155135, which is the item storing
 that description.  So we must take into account and say the
 shorted non-equivalent description.  Maybe we can list all
 equivalent descriptions, and have an interestingness factor.)


(Note that I've been heavily distracted yesterday and today so
 I've lost a lot of the understanding regarding the point of all
 this, which is unfortunate: hence these writings are unusually
 murky: it would be worth getting answers to these questions and
 recording them in the AI.  The AI having the ability to answer
 them is important too.  Remember control rods, sentinels.

 This is helping me to remember:
 /var/lib/release-helper/versions/1/requirements/to.do

 ;; (suppose there is a lisp function without side effects that is
 ;; f(x1,x2,...,xn) = y.  And suppose we have memoized a particular
 ;; value for y.  y could be any lisp data structure or function.
 ;; And we want to know for what values of x1,x2,...,xn does it equal
 ;; y.  Read above in this document to remember why this was
 ;; important (maybe it is to compute equivalent
 ;; expressions/functions (i.e. program equivalence) somehow, by
 ;; computing the inverse of eval or something.  This would be useful
 ;; in order to (for the life of me I cannot remember why this is
 ;; useful, but I know that it is extremely useful to sayer2.)
 ;; Perhaps it is useful bceause you could have functions g and h,
 ;; and you could have g(h) = i, where i is another function, and i
 ;; is in the KB, and g is basically some algorithm that generates
 ;; functions like i which have some desirable property, and you want
 ;; to know programs which are equivalent to h, perhaps to find the
 ;; smallest such programs for the purpose of the sayer object
 ;; compression repository, to find more compact descriptions of
 ;; objects for use in abduction.  Perhaps abduction is the key, we
 ;; want to know which inputs give us this result, because we have
 ;; this result, and we want to know which expressions evaluate to
 ;; it, for instance if g is eval and h is some lisp code,
 ;; i.e. (substr v1530935 0 2), etc, and we want to know for which
 ;; values of v1530935 that evaluates to i, and basically, we don't
 ;; want a list of those values, but a function which enumerates that
 ;; list.  If you provably had such a function, what would be the
 ;; point of it.  Hrm, can't remember.  I know it's very
 ;; useful.  (perhaps you could record in sayer that that g, when
 ;; applied to h, would yield i.  And moreover, for a specific j, you
 ;; could record instances of which h's when computed with g resulted
 ;; in i.  And this is probably useful because )) Perhaps the way to
 ;; solve it would be to realize that f^-1(y) = z | z is the image of
 ;; f^-1 applied to y.  Perhaps we can set up an equation:

 ;; (equals (f x1 x2 ... xn) y) and then go about algorithmically
 ;; solving for f^-1.

 ;; (equals (f^-1 y) (list x1 x2 ... xn)).  Then when we meet some
 ;; particular lisp expression, we can identify the inverse of that
 ;; expression algorithmically, and reiterate, till we have
 ;; reconstructed a function which computes all inverses.  I am not
 ;; sure how this works or if it works exactly, maybe there is
 ;; additional work on it.

 ;; (one thing we can do is record, using sayer2, examples of args to
 ;; the function which resulted in the result value, kinda like AM
 ;; does.)

 ;; )

 ;; (whole point of this is to prove results to different questions
 ;;  that are facing us - to have knowledge about solutions to
 ;;  problems.)

 ;; (which properties?  (well for instance, to questions like this.
 ;; 		      provide examples of instances of properties when asking which
 ;; 		      properties it is trying to prove.)  Some examples would be like
 ;;  runtime, any other statically analyzable properties.  All of this
 ;;  will go into automated program composition stuff.)

 ;; (what is the point of automated program composition?
 ;;  (To lay the context of a problem down, as mapped from text and
 ;;   so on - the world state monitor, to derive solutions to formally
 ;;   specifiable problems.  These problems constitute the frontier
 ;;   surface of our problem solving system, and the goal is to
 ;;   identify relevant problems, as indexed by different users, and
 ;;   struggle to find the solution to them.)
 ;;  )

 ;; (The point of using evolutionary algorithms is that they can help
 ;;  glue together different piecemeal solutions we have in order to )

 )

(one thing we could do is have this be an intelligent way to do saves of large data structures to disk that change partially - for instance, the clear qr/\.voy(\.gz)?$/ files)

(possibly try to intercept calls to (interactive) or whatever to
 get just the calls that the user is invoking in order to get a
 trace of their activity, if there isn't another way)

(the grammatical induction automated programming grammar
 learning/inference may have had things like the sayer2-req stuff that
 starts out: "(suppose there is a lisp function without side effects
 that is ;; f(x1,x2,...,xn) = y.".  The stuff is referenced here:
 where you solve for images etc.
 (see /var/lib/myfrdcsa/capabilities/inductive-programming)
 )
