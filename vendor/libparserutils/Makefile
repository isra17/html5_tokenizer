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
	src/charset/aliases.c \
	src/charset/codec.c \
	src/charset/codecs/codec_8859.c \
	src/charset/codecs/codec_ascii.c \
	src/charset/codecs/codec_ext8.c \
	src/charset/codecs/codec_utf16.c \
	src/charset/codecs/codec_utf8.c \
	src/charset/encodings/utf16.c \
	src/charset/encodings/utf8.c \
	src/input/filter.c \
	src/input/inputstream.c \
	src/utils/buffer.c \
	src/utils/errors.c \
	src/utils/stack.c \
	src/utils/vector.c \
	$(NULL)

C_OBJS = $(patsubst %.c,%.o,$(C_SRC))
CFLAGS += -Isrc -Isrc/charset -Iinclude -fPIC
ifeq ($(OSTYPE), android)
    CFLAGS += -DWITHOUT_ICONV_FILTER
endif

.PHONY: all
all: libparserutils.dummy

src/charset/aliases.inc: build/make-aliases.pl build/Aliases
	perl build/make-aliases.pl

src/charset/aliases.c: src/charset/aliases.inc

libparserutils.a: $(C_OBJS) src/charset/aliases.inc
	$(AR) rcs $@ $^

%.o: %.c
	mkdir -p `dirname $@` && $(CC) $(CFLAGS) -o $@ -c $<

libparserutils.dummy: libparserutils.a
	touch $@

.PHONY: check
check:

.PHONY: clean
clean:
	rm -f *.so *.dylib *.dll *.dummy src/*.o

