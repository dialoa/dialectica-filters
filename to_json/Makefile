DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: to_json.lua sample.md expected.json
	@pandoc -s --lua-filter to_json.lua sample.md $< \
		| $(DIFF) expected.json -

expected.json: sample.md
 	@pandoc -s sample.md -t json -o expected.json