CC=gcc
CFLAGS=-g -Wall
LEXSRC=parse.lex
SRC=alish.c lex.yy.c

all:
	flex $(LEXSRC)
	$(CC) $(CFLAGS) -o alish $(SRC) -lfl
