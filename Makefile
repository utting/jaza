# Makefile for compiling and testing the Z animator under GHC.
.SUFFIXES: .o .hi .lhs .hs .hc .s

# Enable profiling (turn off -auto-all for EParseLib, Parse, Formatting )
# NOTE: you must also disable readline in TextUI.hs.
# GHCFLAGS=-syslib text -syslib util -static -prof -auto-all

GHCFLAGS=-syslib text -syslib util -static

TESTS=eval_test unfold_test lexer_test parse_test formatter_test subs_test \
      reorder_test
PROGS=jaza clpstests

COREOBJ=AST.o Errors.o MyDebug.o
LEXEROBJ=EParseLib.o Lexer.o
PARSEOBJ=$(LEXEROBJ) Parse.o
EVALOBJ=$(PARSEOBJ) FiniteSets.o Subs.o Reorder.o SetSize.o Eval.o
ANIMOBJ=$(COREOBJ) $(EVALOBJ) Formatter.o Animate.o Optimize.o Unfold.o
CLPSOBJ=CLPSType.o CLPSWrite.o BZTT.o

all: $(PROGS) $(TESTS)

help:
	@echo "Possible make targets include:"
	@echo "  jaza   -- compile jaza with GHC"
	@echo "  wc     -- count size of source files"
	@echo "  test   -- compile and run all unit tests"
	@echo "  srcrel -- make a source release into ../jaza_source.tgz"
	@echo "  binrel -- make a Linux binary release into ../jaza_linux.tgz"
	@echo "  winrel -- make a Windows release into ../jaza_winxp.zip"
	@echo "  clean  -- remove generated files"
	@echo "  tags   -- make TAGS file for Emacs"


CLPSTESTOBJ=$(ANIMOBJ) $(CLPSOBJ) CLPSTests.o
clpstests: $(CLPSTESTOBJ)
	ghc $(GHCFLAGS) -o clpstests $(CLPSTESTOBJ)

# Note: -lHSutil -lreadline -lncurses flags have to go in this order,
#       otherwise the linker does not search them in the correct order.
JAZAOBJ=$(ANIMOBJ) $(CLPSOBJ) TextUI.o
jaza: $(JAZAOBJ)
	ghc $(GHCFLAGS) -o jaza $(JAZAOBJ) -lHSutil

Z2BZPOBJ=$(ANIMOBJ) $(CLPSOBJ) Z2BZP.o
z2bzp: $(Z2BZPOBJ)
	ghc $(GHCFLAGS) -o z2bzp $(Z2BZPOBJ) -lHSutil


wc:
	wc $(ANIMOBJ:.o=.*hs)

test: $(TEST)
	for t in $(TESTS); do echo $$t; ./$$t; done

# Definitions for creating releases.
DOCS=jaza/README jaza/COPYING \
     jaza/userman/master.pdf jaza/userman/bbook.zed
# TODO: add  jaza/examples/*.zed
TESTSRC=jaza/tests/Makefile jaza/tests/*.jaza

# This makes a source release.
srcrel:
	cd ..; tar czvf jaza_source.tgz $(DOCS) jaza/*.hs jaza/*.lhs $(TESTSRC)

winrel:
	cd ..; zip jaza_winxp.zip $(DOCS) jaza/jaza.exe $(TESTSRC)

# This makes a binary release.
binrel: jaza
	strip jaza
	cd ..; tar czvf jaza_linux.tgz $(DOCS) jaza/jaza $(TESTSRC)

tags:
	rm -f TAGS
	hstags $(GHC_FLAGS) *.hs *.lhs

clean:
	rm -f *.o *.hi

depend:
	ghc -M $(GHCFLAGS) *.hs FiniteSets.lhs

eval_test: $(COREOBJ) $(EVALOBJ) Eval_Test.o
	ghc $(GHCFLAGS) -o eval_test $(COREOBJ) $(EVALOBJ) Eval_Test.o

lexer_test: $(COREOBJ) $(LEXEROBJ) Lexer_Test.o
	ghc $(GHCFLAGS) -o lexer_test $(COREOBJ) $(LEXEROBJ) Lexer_Test.o

parse_test: $(COREOBJ) $(PARSEOBJ) Parse_Test.o Test_Strings.o
	ghc $(GHCFLAGS) -o parse_test $(COREOBJ) $(PARSEOBJ) Parse_Test.o Test_Strings.o

formatter_test: $(COREOBJ) $(PARSEOBJ) FiniteSets.o Formatter.o Formatter_Test.o Test_Strings.o
	ghc $(GHCFLAGS) -o formatter_test $(COREOBJ) $(PARSEOBJ) \
		FiniteSets.o Formatter.o Formatter_Test.o Test_Strings.o

unfold_test: $(COREOBJ) $(EVALOBJ) Unfold.o Unfold_Test.o
	ghc $(GHCFLAGS) -o unfold_test $(COREOBJ) $(EVALOBJ) Unfold.o Unfold_Test.o

subs_test: $(COREOBJ) $(PARSEOBJ) Unfold.o FiniteSets.o Formatter.o Subs.o Subs_Test.o
	ghc $(GHCFLAGS) -o subs_test $(COREOBJ) $(PARSEOBJ) \
		Unfold.o FiniteSets.o Formatter.o Subs.o Subs_Test.o

reorder_test: $(COREOBJ) $(PARSEOBJ) Unfold.o FiniteSets.o Formatter.o Subs.o SetSize.o Reorder.o ReorderTest.o
	ghc $(GHCFLAGS) -o reorder_test $(COREOBJ) $(PARSEOBJ) \
		Unfold.o FiniteSets.o Formatter.o Subs.o SetSize.o Reorder.o ReorderTest.o


%.hi: %.o
	@:     # do nothing (just record the dependency of .hi on .o)

%.o: %.hs
	ghc $(GHCFLAGS) -c $<

#%.hi: %.lhs
#	ghc $(GHCFLAGS) -c $<

%.o: %.lhs
	ghc $(GHCFLAGS) -c $<





# DO NOT DELETE: Beginning of Haskell dependencies
AST.o : AST.hs
Animate.o : Animate.hs
Animate.o : ./Errors.hi
Animate.o : ./BZTT.hi
Animate.o : ./Eval.hi
Animate.o : ./Optimize.hi
Animate.o : ./Unfold.hi
Animate.o : ./Parse.hi
Animate.o : AST.hi
BZTT.o : BZTT.hs
BZTT.o : ./CLPSWrite.hi
BZTT.o : ./CLPSType.hi
BZTT.o : ./Errors.hi
BZTT.o : ./FiniteSets.hi
BZTT.o : ./Eval.hi
BZTT.o : ./Optimize.hi
BZTT.o : ./Subs.hi
BZTT.o : AST.hi
CLPSTests.o : CLPSTests.hs
CLPSTests.o : ./CLPSWrite.hi
CLPSTests.o : ./Formatter.hi
CLPSTests.o : ./Errors.hi
CLPSTests.o : ./Unfold.hi
CLPSTests.o : ./Parse.hi
CLPSTests.o : AST.hi
CLPSType.o : CLPSType.hs
CLPSType.o : AST.hi
CLPSType.o : ./Errors.hi
CLPSWrite.o : CLPSWrite.hs
CLPSWrite.o : CLPSType.hi
CLPSWrite.o : ./Eval.hi
CLPSWrite.o : ./Errors.hi
CLPSWrite.o : AST.hi
EParseLib.o : EParseLib.hs
EParseTest.o : EParseTest.hs
EParseTest.o : EParseLib.hi
Errors.o : Errors.hs
Errors.o : AST.hi
Eval.o : Eval.hs
Eval.o : ./Reorder.hi
Eval.o : ./Subs.hi
Eval.o : ./FiniteSets.hi
Eval.o : ./SetSize.hi
Eval.o : Errors.hi
Eval.o : AST.hi
Eval_Test.o : Eval_Test.hs
Eval_Test.o : ./FiniteSets.hi
Eval_Test.o : Errors.hi
Eval_Test.o : Eval.hi
Formatter.o : Formatter.hs
Formatter.o : ./FiniteSets.hi
Formatter.o : ./Parse.hi
Formatter.o : AST.hi
Formatter_Test.o : Formatter_Test.hs
Formatter_Test.o : ./Test_Strings.hi
Formatter_Test.o : Formatter.hi
Formatter_Test.o : ./Parse.hi
Formatter_Test.o : AST.hi
HigherOrder.o : HigherOrder.hs
Lexer.o : Lexer.hs
Lexer.o : EParseLib.hi
Lexer_Test.o : Lexer_Test.hs
Lexer_Test.o : Lexer.hi
Lexer_Test.o : EParseLib.hi
MyDebug.o : MyDebug.hs
Optimize.o : Optimize.hs
Optimize.o : MyDebug.hi
Optimize.o : Eval.hi
Optimize.o : ./Unfold.hi
Optimize.o : ./Reorder.hi
Optimize.o : ./Subs.hi
Optimize.o : AST.hi
Parse.o : Parse.hs
Parse.o : Errors.hi
Parse.o : AST.hi
Parse.o : Lexer.hi
Parse.o : EParseLib.hi
Parse_Test.o : Parse_Test.hs
Parse_Test.o : ./Test_Strings.hi
Parse_Test.o : Lexer.hi
Parse_Test.o : Parse.hi
Reorder.o : Reorder.hs
Reorder.o : Parse.hi
Reorder.o : MyDebug.hi
Reorder.o : ./Subs.hi
Reorder.o : ./SetSize.hi
Reorder.o : AST.hi
ReorderTest.o : ReorderTest.hs
ReorderTest.o : Reorder.hi
ReorderTest.o : Formatter.hi
ReorderTest.o : ./Unfold.hi
ReorderTest.o : Parse.hi
ReorderTest.o : Errors.hi
ReorderTest.o : AST.hi
SetSize.o : SetSize.hs
SetSize.o : ./FiniteSets.hi
SetSize.o : Errors.hi
SetSize.o : AST.hi
Subs.o : Subs.hs
Subs.o : ./FiniteSets.hi
Subs.o : AST.hi
Subs_Test.o : Subs_Test.hs
Subs_Test.o : Formatter.hi
Subs_Test.o : ./Unfold.hi
Subs_Test.o : Parse.hi
Subs_Test.o : Subs.hi
Subs_Test.o : Errors.hi
Subs_Test.o : AST.hi
Test.o : Test.hs
Test_Strings.o : Test_Strings.hs
Test_Strings.o : AST.hi
TextUI.o : TextUI.hs
TextUI.o : Formatter.hi
TextUI.o : Animate.hi
TextUI.o : Errors.hi
TextUI.o : AST.hi
Unfold.o : Unfold.hs
Unfold.o : Subs.hi
Unfold.o : ./FiniteSets.hi
Unfold.o : Errors.hi
Unfold.o : AST.hi
Unfold_Test.o : Unfold_Test.hs
Unfold_Test.o : Unfold.hi
Z2BZP.o : Z2BZP.hs
Z2BZP.o : Formatter.hi
Z2BZP.o : Animate.hi
Z2BZP.o : Errors.hi
Z2BZP.o : AST.hi
FiniteSets.o : FiniteSets.lhs
FiniteSets.o : AST.hi
# DO NOT DELETE: End of Haskell dependencies
