.PHONY:	clean clean-html all check deploy debug

XSLTPROC = xsltproc --timing --stringparam debug.datedfiles no # -v

docs:	docs/aut-forms-arthur-selberg.pdf aut-forms-arthur-selberg-pretty.xml aut-forms-arthur-selberg.xsl filter.xsl
	mkdir -p docs
	cd docs/; \
	$(XSLTPROC) ../aut-forms-arthur-selberg.xsl ../aut-forms-arthur-selberg-pretty.xml

aut-forms-arthur-selberg.tex:	aut-forms-arthur-selberg-pretty.xml aut-forms-arthur-selberg-latex.xsl filter.xsl
	$(XSLTPROC) aut-forms-arthur-selberg-latex.xsl aut-forms-arthur-selberg-pretty.xml

aut-forms-arthur-selberg.md:	aut-forms-arthur-selberg-pretty.xml filter.xsl
	$(XSLTPROC) ../mathbook/xsl/mathbook-markdown-common.xsl aut-forms-arthur-selberg-wrapper.xml > aut-forms-arthur-selberg.md

docs/aut-forms-arthur-selberg.pdf:	aut-forms-arthur-selberg.tex
	latexmk -pdf -output-directory=docs -pdflatex="pdflatex -interaction=nonstopmode"  aut-forms-arthur-selberg.tex

aut-forms-arthur-selberg-wrapper.xml:	*.pug pug-plugin.json
	pug -O pug-plugin.json --extension xml aut-forms-arthur-selberg-wrapper.pug
	sed -i 's/proofcase/case/g' aut-forms-arthur-selberg-wrapper.xml # Fix proofcase->case !! UGLY HACK, SAD

aut-forms-arthur-selberg-pretty.xml: aut-forms-arthur-selberg-wrapper.xml
	xmllint --pretty 2 aut-forms-arthur-selberg-wrapper.xml > aut-forms-arthur-selberg-pretty.xml

all:	docs docs/aut-forms-arthur-selberg.pdf

deploy: clean-html aut-forms-arthur-selberg-wrapper.xml docs
	cp aut-forms-arthur-selberg-wrapper.xml docs/aut-forms-arthur-selberg.xml
	./deploy.sh

debug:	*.pug pug-plugin.json
	pug -O pug-plugin.json --pretty --extension xml aut-forms-arthur-selberg-wrapper.pug

check:	aut-forms-arthur-selberg-pretty.xml
	jing ../mathbook/schema/pretext.rng aut-forms-arthur-selberg-pretty.xml
	#xmllint --xinclude --postvalid --noout --dtdvalid ../mathbook/schema/dtd/mathbook.dtd aut-forms-arthur-selberg-pretty.xml

clean-html:
	rm -rf docs

clean:	clean-html
	rm -f aut-forms-arthur-selberg.md
	rm -f aut-forms-arthur-selberg*.tex
	rm -f aut-forms-arthur-selberg*.xml
