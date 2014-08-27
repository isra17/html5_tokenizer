#include <ruby.h>
#include <hubbub/hubbub.h>
#include <hubbub/tokeniser.h>
#include <parserutils/input/inputstream.h>

typedef struct {
  parserutils_inputstream* stream;
  hubbub_tokeniser* tokenizer;
} tokenizer_engine_t;

VALUE mHtml5Tokenizer = Qnil;

VALUE cTokenizer = Qnil;
static void Init_Tokenizer();
static VALUE Tokenizer_new(VALUE rb_class);
static VALUE Tokenizer_insert(VALUE rb_self, VALUE rb_data);
static VALUE Tokenizer_run(VALUE rb_self);
static void Tokenizer_free(void *p);

static hubbub_error token_handler(const hubbub_token *token, void *pw);

void Init_html5_tokenizer();

static void* rb_realloc(void* ptr, size_t len, void* pw) {
	return REALLOC_N(ptr, char, len);
}

void Init_html5_tokenizer() {
  mHtml5Tokenizer = rb_define_module("Html5Tokenizer");
  Init_Tokenizer();
}

void Init_Tokenizer() {
  cTokenizer = rb_define_class_under(mHtml5Tokenizer, "Tokenizer", rb_cObject);
  rb_define_singleton_method(cTokenizer, "new", Tokenizer_new, 0);
  rb_define_method(cTokenizer, "insert", Tokenizer_insert, 1);
  rb_define_method(cTokenizer, "run", Tokenizer_run, 0);
}

VALUE Tokenizer_new(VALUE rb_class) {
  tokenizer_engine_t* tok_eng = ALLOC(tokenizer_engine_t);

  parserutils_inputstream_create("UTF-8", 0, NULL, rb_realloc, NULL, &tok_eng->stream);
  hubbub_tokeniser_create(tok_eng->stream, rb_realloc, NULL, &tok_eng->tokenizer);

  VALUE rb_tdata = Data_Wrap_Struct(rb_class, 0, Tokenizer_free, tok_eng);
  rb_obj_call_init(rb_tdata, 0, 0);
  return rb_tdata;
}

VALUE Tokenizer_insert(VALUE rb_self, VALUE rb_data) {
  tokenizer_engine_t* tok_eng;
  Data_Get_Struct(rb_self, tokenizer_engine_t, tok_eng);

  parserutils_inputstream_append(tok_eng->stream, (uint8_t*) RSTRING_PTR(rb_data), RSTRING_LEN(rb_data));
  return Qnil;
}

VALUE Tokenizer_run(VALUE rb_self) {
  tokenizer_engine_t* tok_eng;
  Data_Get_Struct(rb_self, tokenizer_engine_t, tok_eng);

  hubbub_tokeniser_optparams params;
  params.token_handler.handler = token_handler;
  params.token_handler.pw = NULL;

  hubbub_tokeniser_setopt(tok_eng->tokenizer, HUBBUB_TOKENISER_TOKEN_HANDLER, &params);
  hubbub_tokeniser_run(tok_eng->tokenizer);
  return Qnil;
}

void Tokenizer_free(void *p) {
  tokenizer_engine_t* tok_eng = p;

	hubbub_tokeniser_destroy(tok_eng->tokenizer);
	parserutils_inputstream_destroy(tok_eng->stream);
  free(tok_eng);
}

hubbub_error token_handler(const hubbub_token *token, void *pw) {
  if (rb_block_given_p()) {
    rb_yield(INT2FIX(token->type));
  }

  return HUBBUB_OK;
}
