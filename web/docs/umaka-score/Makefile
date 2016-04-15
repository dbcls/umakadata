TARGET=umaka-score

all:
	pdflatex ${TARGET}
	bibtex   ${TARGET}
	pdflatex ${TARGET}
	pdflatex ${TARGET}

clean:
	rm *.aux *.bbl *.blg *.log *.pdf *.html *.lg *.dvi *.idv
