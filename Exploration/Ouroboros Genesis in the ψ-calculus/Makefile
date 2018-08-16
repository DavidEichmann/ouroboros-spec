Genesis.pdf: Genesis.tex references.bib
	pdflatex Genesis.tex
	bibtex Genesis
	pdflatex Genesis.tex
	pdflatex Genesis.tex

Genesis.tex: Genesis.lhs
	lhs2TeX -o Genesis.tex Genesis.lhs

.PHONY: clean
clean:
	rm -f *.aux *.bbl *.blg *.log *.ptb *.tex *.pdf *.toc

.PHONY: ghcid
ghcid:
	ghcid --command='cabal new-repl genesis'

# watch the .lhs file and call make whenever it changes
.PHONE: watch
watch:
	while inotifywait -e close_write Genesis.lhs -e close_write references.bib ; do make ; done
