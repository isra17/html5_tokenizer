#include <ruby.h>
#include <hubbub/hubbub.h>
#include <hubbub/tokeniser.h>
#include <parserutils/input/inputstream.h>

#define INT2BOOL(x) (x?Qtrue:Qfalse)
#define STR2SYM(s) ID2SYM(rb_intern(s))

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
static VALUE str_hubbub_to_rb(hubbub_string str);

VALUE mHtml5Tokenizer;
void Init_html5_tokenizer();

VALUE cToken;
VALUE cDoctype;
VALUE cTag;
VALUE cStartTag;
VALUE cEndTag;
VALUE cComment;
VALUE cCharacter;
VALUE cEof;
void Init_Token();
static VALUE wrap_token(const hubbub_token* token);

static void* rb_realloc(void* ptr, size_t len, void* pw) {
	return REALLOC_N(ptr, char, len);
}

void Init_html5_tokenizer() {
  mHtml5Tokenizer = rb_define_module("Html5Tokenizer");
  Init_Tokenizer();
  Init_Token();
}

// ====== Tokenizer class ======

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
  VALUE rb_token = wrap_token(token);

  if (rb_block_given_p()) {
    rb_yield(rb_token);
  }

  return HUBBUB_OK;
}


// ======= Token wrapper =========

void Init_Token() {
  cToken = rb_define_class_under(mHtml5Tokenizer, "Token", rb_cObject);
  cDoctype = rb_define_class_under(cToken, "Doctype", cToken);
  cTag = rb_define_class_under(cToken, "Tag", cToken);
  cStartTag = rb_define_class_under(cToken, "StartTag", cTag);
  cEndTag = rb_define_class_under(cToken, "EndTag", cTag);
  cComment = rb_define_class_under(cToken, "Comment", cToken);
  cCharacter = rb_define_class_under(cToken, "Character", cToken);
  cEof = rb_define_class_under(cToken, "Eof", cToken);
}

VALUE str_hubbub_to_rb(const hubbub_string str) {
  return rb_str_new((char*)str.ptr, str.len);
}

VALUE hubbub_ns_to_sym(hubbub_ns ns) {
  switch(ns) {
  case HUBBUB_NS_NULL: return STR2SYM("ns_null");
  case HUBBUB_NS_HTML: return STR2SYM("ns_html");
  case HUBBUB_NS_MATHML: return STR2SYM("ns_mathml");
  case HUBBUB_NS_SVG: return STR2SYM("ns_svg");
  case HUBBUB_NS_XLINK: return STR2SYM("ns_xlink");
  case HUBBUB_NS_XML: return STR2SYM("ns_xml");
  case HUBBUB_NS_XMLNS: return STR2SYM("ns_xmlns");
  }
  return Qnil;
}

VALUE hubbub_attributes_to_hash(size_t len, hubbub_attribute* attributes) {
  VALUE rb_attributes = rb_hash_new();
  for(int i = 0; i < len; i++) {
    VALUE key = str_hubbub_to_rb(attributes[i].name);
    VALUE value = str_hubbub_to_rb(attributes[i].value);
    rb_hash_aset(rb_attributes, key, value);
  }
  return rb_attributes;
}

VALUE wrap_token(const hubbub_token* token) {
  switch(token->type){
  case HUBBUB_TOKEN_DOCTYPE: {
    VALUE argv[] = {
      str_hubbub_to_rb(token->data.doctype.name),
      INT2BOOL(token->data.doctype.public_missing),
      str_hubbub_to_rb(token->data.doctype.public_id),
      INT2BOOL(token->data.doctype.system_missing),
      str_hubbub_to_rb(token->data.doctype.system_id),
      INT2BOOL(token->data.doctype.force_quirks)
    };

    return rb_class_new_instance(sizeof(argv)/sizeof(argv[0]), argv, cDoctype);
  }
  case HUBBUB_TOKEN_END_TAG:
  case HUBBUB_TOKEN_START_TAG: {
    VALUE argv[] = {
      hubbub_ns_to_sym(token->data.tag.ns),
      str_hubbub_to_rb(token->data.tag.name),
      hubbub_attributes_to_hash(token->data.tag.n_attributes, token->data.tag.attributes),
      INT2BOOL(token->data.tag.self_closing)
    };

    VALUE klass = cEndTag;
    if(token->type == HUBBUB_TOKEN_START_TAG) klass = cStartTag;
    return rb_class_new_instance(sizeof(argv)/sizeof(argv[0]), argv, klass);
  }
  case HUBBUB_TOKEN_COMMENT:{
    VALUE value = str_hubbub_to_rb(token->data.comment);
    return rb_class_new_instance(1, &value, cComment);
  }
  case HUBBUB_TOKEN_CHARACTER:{
    VALUE value = str_hubbub_to_rb(token->data.character);
    return rb_class_new_instance(1, &value, cCharacter);
  }
  case HUBBUB_TOKEN_EOF:
    return rb_class_new_instance(0, 0, cEof);
  }

  return Qnil;
}

