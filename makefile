quotes: src/pratico.flex
	mkdir -p out/
	flex -o out/lex.yy.c src/pratico.flex
	cc -o out/a.out out/lex.yy.c `pkg-config --cflags --libs glib-2.0` -lglib-2.0

install: out/a.out
	 sudo mv out/a.out /opt/wikiquotes

clean: out/a.out out/lex.yy.c
	rm -r out
