#include <ruby.h>
#include <hubbub/hubbub.h>
#include <parserutils/input/inputstream.h>

VALUE Html5Tokenizer = Qnil;

static void* myrealloc(void* ptr, size_t len, void* pw) {
	return realloc(ptr, len);
}


void Init_html5_tokenizer();

void Init_html5_tokenizer() {
  Html5Tokenizer = rb_define_module("Html5Tokenizer");

  parserutils_inputstream *stream;
  parserutils_inputstream_create("UTF-8", 0, NULL, myrealloc, NULL, &stream);
}
