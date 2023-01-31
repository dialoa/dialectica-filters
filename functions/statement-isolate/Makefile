DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: tex

tex: statement-isolate.lua sample.md
	@pandoc -L statement-isolate.lua -L sample.md \
	--to=latex | $(DIFF) expected.tex -

expected.tex: statement-isolate.lua sample.md
	@pandoc -L statement-isolate.lua sample.md \
	--output expected.tex
