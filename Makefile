public: public/index.html public/elmSelect.js public/main.js

public/%: src/%
	@mkdir -p ${@D}
	cp $< $@

public/main.js: src/Main.elm $(shell find src -name '*.elm')
	@mkdir -p ${@D}
	elm make --output $@ $<
