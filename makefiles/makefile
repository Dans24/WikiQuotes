build:
	flex.exe wikiquotes.fl
	gcc -o converter lex.yy.c `pkg-config --cflags --libs glib-2.0` -lglib-2.0