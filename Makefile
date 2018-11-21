######################################################
COURSE=cs131f
ORG=ucsd-cse131-fa18
ASGN=05
COMPILER=egg 
EXT=egg 
######################################################

COMPILEREXEC=stack exec -- $(COMPILER)
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
  FORMAT=aout
else
ifeq ($(UNAME), Darwin)
  FORMAT=macho
else
ifeq ($(UNAME), CYGWIN_NT-10.0)
  FORMAT=win
  WINSTUFF=-target i686-pc-mingw32
endif
endif
endif

.PHONY: test bin build clean distclean turnin \
	$(ASMS) $(OBJS) $(RUNS) $(RESULTS)

test: clean
	stack test

bin:
	stack install

build:
	stack build

tests/output/%.vresult: tests/output/%.run
	valgrind $< > $@

tests/output/%.result: tests/output/%.run FORCE
	$< > $@

tests/output/%.run: tests/output/%.o c-bits/main.c FORCE
	clang $(WINSTUFF) -g -m32 -mstackrealign -o $@ c-bits/main.c $<

tests/output/%.o: tests/output/%.s FORCE
	nasm -f $(FORMAT) -o $@ $<

tests/output/%.s: tests/input/%.$(EXT) FORCE
	$(COMPILEREXEC) $< > $@

clean:
	rm -rf tests/output/*.o tests/output/*.s tests/output/*.dSYM tests/output/*.run tests/output/*.log tests/output/*.result

distclean: clean
	stack clean
	rm -rf .stack-work

tags:
	hasktags -x -c lib/

turnin:
	git commit -a -m "turnin"
	git push origin master

upstream:
	git remote add upstream git@github.com:$(ORG)/$(ASGN)-$(COMPILER).git

update:
	git pull upstream master



# aliases

INPUTS  := $(patsubst tests/input/%.$(EXT),%,$(wildcard tests/input/*.$(EXT)))
ASMS    := $(patsubst %,%-s,$(INPUTS))
OBJS    := $(patsubst %,%-o,$(INPUTS))
RUNS    := $(patsubst %,%-run,$(INPUTS))
RESULTS := $(patsubst %,%-result,$(INPUTS))

$(ASMS): %-s: tests/output/%.s
	cat $<
$(OBJS): %-o: tests/output/%.o
$(RUNS): %-run: tests/output/%.run
$(RESULTS): %-result: tests/output/%.result
	cat $<

FORCE:
