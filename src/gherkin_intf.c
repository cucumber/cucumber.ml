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
#include "pickle_argument.h"
#include "pickle_string.h"

#include "caml/mlvalues.h"
#include "caml/alloc.h"
#include "caml/memory.h"

char * char_of_wchar(wchar_t *);
CAMLprim value create_ocaml_pickle(const Pickle *);
CAMLprim value create_ocaml_loc_list(const PickleLocations *);
CAMLprim value create_ocaml_tag_list(const PickleTags *);
CAMLprim value create_ocaml_loc(const PickleLocation *);
CAMLprim value create_ocaml_tag(const PickleTag *);
CAMLprim value create_ocaml_step_list(const PickleSteps *);
CAMLprim value create_ocaml_step(const PickleStep *);
CAMLprim value create_ocaml_docstring(const PickleArgument *);

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
    Event_delete((const Event*)pickle_event);
  }
  
  FileReader_delete(file_reader);
  Event_delete((const Event*)source_event);
  Compiler_delete(compiler);
  Parser_delete(parser);
  AstBuilder_delete(builder);
  TokenMatcher_delete(token_matcher);
  
  CAMLreturn(oPickleList);
}

CAMLprim value create_ocaml_pickle(const Pickle *pickle) {
  CAMLparam0();
  CAMLlocal4(oPickle, oLocList, oTagList, oStepList);
  oPickle = caml_alloc(5, 0);
  
  size_t lang_len = wcstombs(NULL, pickle->language, 0);
  char lang[lang_len + 1];
  wcstombs(lang, pickle->language, lang_len + 1);
    
  size_t name_len = wcstombs(NULL, pickle->name, 0);
  char name[name_len + 1];
  wcstombs(name, pickle->name, name_len + 1);

  oLocList = create_ocaml_loc_list(pickle->locations);
  oTagList = create_ocaml_tag_list(pickle->tags);
  oStepList = create_ocaml_step_list(pickle->steps);
  
  Store_field(oPickle, 0, caml_copy_string(lang));
  Store_field(oPickle, 1, caml_copy_string(name));
  Store_field(oPickle, 2, oLocList);
  Store_field(oPickle, 3, oTagList);
  Store_field(oPickle, 4, oStepList);

  CAMLreturn(oPickle);
}

CAMLprim value create_ocaml_loc_list(const PickleLocations *locs) {
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

CAMLprim value create_ocaml_loc(const PickleLocation *loc) {
  CAMLparam0();
  CAMLlocal1(oLoc);

  oLoc = caml_alloc(2, 0);

  Store_field(oLoc, 0, caml_copy_int32(loc->line));
  Store_field(oLoc, 1, caml_copy_int32(loc->column));

  CAMLreturn(oLoc);
}

CAMLprim value create_ocaml_tag(const PickleTag *tag) {
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

CAMLprim value create_ocaml_tag_list(const PickleTags *tags) {
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

CAMLprim value create_ocaml_step(const PickleStep *step) {
    CAMLparam0();
    CAMLlocal2(oStep, arg);

    oStep = caml_alloc(3, 0);

    Store_field(oStep, 0, create_ocaml_loc_list(step->locations));

    char *text = char_of_wchar(step->text);
    
    Store_field(oStep, 1, caml_copy_string(text));

    free(text);
    
    if(step->argument == NULL) {
      Store_field(oStep, 2, Val_int(0));
      CAMLreturn(oStep);
    }
    
    switch(step->argument->type) {
    case Argument_String:
      arg = caml_alloc(1, 0);
      Store_field(arg, 0, create_ocaml_docstring(step->argument));
      Store_field(oStep, 2, arg);
      break;
    case Argument_Table:
      Store_field(oStep, 2, Val_int(1));
      break;
    default:
      Store_field(oStep, 2, Val_int(0));      
    }

    CAMLreturn(oStep);
}

CAMLprim value create_ocaml_step_list(const PickleSteps *steps) {
  CAMLparam0();

  CAMLlocal3(oStepList, oStep, cons);

  oStepList = Val_emptylist;

  if(steps == NULL) {
    CAMLreturn(oStepList);
  }
  
  for(int i = 0; i < steps->step_count; ++i) {
    cons = caml_alloc(2, 0);
    oStep = create_ocaml_step(&steps->steps[i]);
    Store_field(cons, 0, oStep);
    Store_field(cons, 1, oStepList);

    oStepList = cons;
  }

  CAMLreturn(oStepList);  
}

CAMLprim value create_ocaml_docstring(const PickleArgument *arg) {
  CAMLparam0();
  CAMLlocal1(oDocString);

  oDocString = caml_alloc(2, 0);

  const PickleString *docstring = (const PickleString*) arg;
  char *content = char_of_wchar(docstring->content);
  
  Store_field(oDocString, 0, create_ocaml_loc(&docstring->location));
  Store_field(oDocString, 1, caml_copy_string(content));

  free(content);

  CAMLreturn(oDocString);
}

char * char_of_wchar(wchar_t *text) {
    size_t text_len = wcstombs(NULL, text, 0);
    char *text_out = malloc(sizeof(char) * text_len);
    wcstombs(text_out, text, text_len + 1);

    return text_out;
}
