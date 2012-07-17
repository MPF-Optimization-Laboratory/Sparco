JEMDOC = ./jemdoc.py -c sparco.conf

objects := $(patsubst %.jemdoc,%.html, $(wildcard *.jemdoc))

matlabguides := $(wildcard matlab_published/html/*.html)

sparcohelp := htmlhelp/problems_list.html

all: ${objects}

%.html: %.jemdoc MENU ${matlabguides} ${spothelp}
	${JEMDOC} $<
