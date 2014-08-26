UNAME=$(shell uname)

ifeq ($(UNAME),Darwin)
    OSTYPE=darwin
endif
ifeq ($(UNAME),Linux)
    OSTYPE=linux
endif
ifeq ($(CFG_OSTYPE),linux-androideabi)
    OSTYPE=android
endif

C_SRC= \
	src/charset/detect.c \
	src/tokeniser/entities.c \
	src/tokeniser/tokeniser.c \
	src/utils/errors.c \
	src/utils/string.c \
	$(NULL)

C_OBJS = $(patsubst %.c,%.o,$(C_SRC))
# -DNDEBUG is here to keep hubbub from spewing out debug info to the consolo
CFLAGS += -Isrc -Iinclude -I../libparserutils/include -fPIC -DNDEBUG

.PHONY: all
all: libhubbub.dummy

src/tokeniser/entities.inc: build/make-entities.pl build/Entities
	perl build/make-entities.pl

src/tokeniser/entities.o: src/tokeniser/entities.inc

libhubbub.a: $(C_OBJS)
	$(AR) rcs $@ $^

%.o: %.c
	mkdir -p `dirname $@` && $(CC) $(CFLAGS) -o $@ -c $<

libhubbub.dummy: libhubbub.a
	touch $@

.PHONY: check
check:

.PHONY: clean
clean:
	rm -f *.so *.dylib *.dll *.dummy */*.o */*/*.o

