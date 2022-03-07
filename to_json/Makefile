DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

# remove the newlines from stdin before comparing results
test: sample.md to_json.lua expected.json
	@pandoc --lua-filter to_json.lua $< \
	| tr -d '\n' \
	| $(DIFF) expected.json -

expected.json: sample.md
	@pandoc -s sample.md -t json -o expected.json