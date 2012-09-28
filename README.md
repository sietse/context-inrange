context-inrange
===============

Turn \inrange{Figures}[fig:a, fig:c, fig:d, fig:e] into "Figures 1, 3-5".

## Usage

Place `inrange.lua` and `inrange.mkvi` in your directory (or elsewhere
on the search path), and type 

    \usemodule[inrange]

    \inrange{Figures}{?}[fig:a, fig:b, fig:c]

to get "Figures 1-3?".

## TODO

* Figure out how to get the figure number string _with_ prefixes, like
  '1.2.3'. Then modify `inrange.lua` to handle those (notes on what to
  alter are in the file, marked with `TODO`.)

* Figure out how to let `\inrange` be a valid command for
  `\definereferenceformat`. The naïve approach,
  `\definereferenceformat[inr][command=\inrange]`, doesn't work: the `\goto` is
  baked right into `\strc_references_pickup_goto_indeed`. See 
  [strc-ref.mkvi](http://repo.or.cz/w/context.git/blob/HEAD:/tex/context/base/strc-ref.mkvi).
  Here is the baked-in \goto:

      \doifreferencefoundelse{#label} % we need to resolve the text
        {\goto{\referencesequence}[#label]}
        {\let\currentreferencecontent\dummyreference
          \goto{\referencesequence}[#label]}%
      \strc_references_stop_goto}
