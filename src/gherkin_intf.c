#include <stdlib.h>
#include <stdio.h>
#include <locale.h>
#include <wchar.h>
#include <string.h>

#include "file_reader.h"
#include "source_event.h"
#include "token_scanner.h"
#include "token_matcher.h"
#include "string_token_scanner.h"
#include "parser.h"
#include "ast_builder.h"
#include "gherkin_document_event.h"
#include "compiler.h"
#include "pickle_event.h"
#include "event.h"

#include "caml/mlvalues.h"
#include "caml/alloc.h"
#include "caml/memory.h"

value create_ocaml_pickle(const Pickle *);
value create_ocaml_loc_list(const PickleLocations *);
value create_ocaml_tag_list(const PickleTags *);
value create_ocaml_loc(const PickleLocation *);


CAMLprim value load_feature_file(value fileName) {
  setlocale(LC_ALL, "en_US.UTF-8");
  setbuf(stdout, NULL);
  
  CAMLparam1(fileName);
  CAMLlocal3(oPickleList, oPickle, cons);
  char *sFileName = String_val(fileName);

  FileReader *file_reader = FileReader_new(sFileName);
  SourceEvent *source_event = SourceEvent_new(sFileName, FileReader_read(file_reader));
  TokenScanner *token_scanner = StringTokenScanner_new(source_event->source);
  TokenMatcher* token_matcher = TokenMatcher_new(L"en");
  Builder* builder = AstBuilder_new();
  Parser* parser = Parser_new(builder);
  Compiler* compiler = Compiler_new();
  
  Parser_parse(parser, token_matcher, token_scanner);

  const GherkinDocumentEvent* gherkin_document_event = GherkinDocumentEvent_new(sFileName, AstBuilder_get_result(builder));

  Compiler_compile(compiler, gherkin_document_event->gherkin_document);

  Event_delete((const Event*)gherkin_document_event);

  oPickleList = Val_emptylist;
  
  while(Compiler_has_more_pickles(compiler)) {
    const PickleEvent* pickle_event = PickleEvent_new(sFileName, Compiler_next_pickle(compiler));
    const Pickle *pickle = pickle_event->pickle;

    oPickle = create_ocaml_pickle(pickle);

    cons = caml_alloc(2, 0);

    Store_field(cons, 0, oPickle);
    Store_field(cons, 1, oPickleList);

    oPickleList = cons;
  }
  
  FileReader_delete(file_reader);
  Event_delete((const Event*)source_event);
  Compiler_delete(compiler);
  Parser_delete(parser);
  AstBuilder_delete(builder);
  TokenMatcher_delete(token_matcher);
  
  CAMLreturn(oPickleList);
}

value create_ocaml_pickle(const Pickle *pickle) {
  CAMLparam0();
  CAMLlocal3(oPickle, oLocList, oTagList);
  oPickle = caml_alloc(2, 0);
  
  size_t lang_len = wcstombs(NULL, pickle->language, 0);
  char lang[lang_len + 1];
  wcstombs(lang, pickle->language, lang_len + 1);
    
  size_t name_len = wcstombs(NULL, pickle->name, 0);
  char name[name_len + 1];
  wcstombs(name, pickle->name, name_len + 1);

  oLocList = create_ocaml_loc_list(pickle->locations);
  oTagList = create_ocaml_tag_list(pickle->tags);
  
  Store_field(oPickle, 0, caml_copy_string(lang));
  Store_field(oPickle, 1, caml_copy_string(name));
  Store_field(oPickle, 2, oLocList);
  Store_field(oPickle, 3, oTagList);

  CAMLreturn(oPickle);
}

value create_ocaml_loc_list(const PickleLocations *locs) {
  CAMLparam0();
  CAMLlocal3(oLocList, oLoc, cons);

  oLocList = Val_emptylist;

  if(locs == NULL) {
    CAMLreturn(oLocList);
  }
  
  for(int i = 0; i < locs->location_count; ++i) {
    cons = caml_alloc(2, 0);
    oLoc = create_ocaml_loc(&locs->locations[i]);
    
    Store_field(cons, 0, oLoc);
    Store_field(cons, 1, oLocList);

    oLocList = cons;
  }

  CAMLreturn(oLocList);
}

value create_ocaml_loc(const PickleLocation *loc) {
  CAMLparam0();
  CAMLlocal1(oLoc);

  oLoc = caml_alloc(2, 0);

  Store_field(oLoc, 0, caml_copy_int32(loc->line));
  Store_field(oLoc, 1, caml_copy_int32(loc->column));

  CAMLreturn(oLoc);
}

value create_ocaml_tag(const PickleTag *tag) {
  CAMLparam0();
  CAMLlocal1(oTag);

  oTag = caml_alloc(2, 0);

  Store_field(oTag, 0, create_ocaml_loc(&tag->location));

  size_t name_len = wcstombs(NULL, tag->name, 0);
  char name[name_len + 1];
  wcstombs(name, tag->name, name_len + 1);
  
  Store_field(oTag, 1, caml_copy_string(name));

  CAMLreturn(oTag);
}

value create_ocaml_tag_list(const PickleTags *tags) {
  CAMLparam0();
  CAMLlocal3(oTagList, oTag, cons);

  oTagList = Val_emptylist;

  if(tags == NULL) {
    CAMLreturn(oTagList);
  }
  
  for(int i = 0; i < tags->tag_count; ++i) {
    cons = caml_alloc(2, 0);
    oTag = create_ocaml_tag(&tags->tags[i]);
    Store_field(cons, 0, oTag);
    Store_field(cons, 1, oTagList);

    oTagList = cons;
  }

  CAMLreturn(oTagList);
}
