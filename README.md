Skills-Graph
============

## Intro
This is an example of [Xach](http://www.xach.com/)'s [wormtrails](https://github.com/xach/wormtrails) illustrating skills over time.

See generated streamgraph: http://pezely.com/daniel/languages

## Generating a new Streamgraph
This has only been tested with [SBCL](http://sbcl.org/platform-table.html) compiler and packages installed by [Quicklisp](http://www.quicklisp.org/).

## Dependencies other than SBCL & Quicklisp
Run:

	mkdir -p ~/.local/share/common-lisp/source
	cd ~/.local/share/common-lisp/source/
    git clone https://github.com/xach/wormtrails.git
    git clone https://github.com/xach/geometry.git
    sbcl \
	  --eval "(mapcar 'ql:quickload '(vecto zpb-ttf html-template split-sequence fare-csv))" \
	  --eval '(quit)'
    sbcl --eval "(require 'wormtrails)" --eval '(quit)'

## Edit Content
Review & update `languages.csv` file.

## Run program
This generates `skills.png` and `skills.html` fragment:

    sbcl --load streamgraph.lisp --eval '(quit)'

## Finish .html
Append closing HTML tags:

    cat skills-annotation.html >> skills.html

## Edit Parameters
Color selection changes depending upon number of total data points, not
unique labels.  Color values therefore seem to be hit or miss, but actually,
it's based upon a 360 degree color wheel within the HSV space, locked-down
to the hue dimension.  Using multiples of Phi ("golden ratio") 1.618 seem to offer
fairness in color diversity, but experimentation is required for each year's
set of values.
