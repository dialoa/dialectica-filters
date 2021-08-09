DIFF ?= diff --strip-trailing-cr -u

.PHONY: test

test: markdown docx

markdown: sections-to-meta.lua sample.md expected.md
	@pandoc --standalone --lua-filter sections-to-meta.lua --to=markdown sample.md \
		| $(DIFF) expected.md -

docx: sections-to-meta.lua docxsample.docx docx-expected.md 
	@pandoc --standalone --lua-filter sections-to-meta.lua --to=markdown docxsample.docx \
		| $(DIFF) docx-expected.md -

expected.md: sections-to-meta.lua sample.md
	@pandoc --standalone --lua-filter sections-to-meta.lua --to=markdown sample.md \
	--output expected.md

docx-expected.md: sections-to-meta.lua docxsample.docx
	@pandoc --standalone --lua-filter sections-to-meta.lua --to=markdown docxsample.docx \
	--output docx-expected.md

clean:
	@rm -f expected.md docx-expected.json