/* 
 * parser.y - Parser utility for the DHBW compiler
 */

%{
	#include "include/utlist.h" 
	#include "symtable.h"
	#include "ir_code_gen.h"
	#include <stdio.h>	

	void yyerror (char const *);
%}
 
%union{
	int num;
	char *id;
	struct symInt *sInt;
	struct symFunc *sFunc;
	/*STRUCT ZUR WEITERGABE VON INFOS NACH OBEN... %type ...*/
}

%debug
%locations
%start program

/*
 * One shift/reduce conflict is expected for the "dangling-else" problem. This
 * conflict however is solved by the default behavior of bison for shift/reduce 
 * conflicts (shift action). The default behavior of bison corresponds to what
 * we want bison to do: SHIFT if the lookahead is 'ELSE' in order to bind the 'ELSE' to
 * the last open if-clause. 
 */
%expect 1

%token DO WHILE
%token IF ELSE
%token <id>INT <id>VOID
%token RETURN
%token COLON COMMA SEMICOLON
%token BRACE_OPEN BRACE_CLOSE

%token <id>ID
%token <num>NUM

%right ASSIGN 
%left  LOGICAL_OR
%left  LOGICAL_AND
%left  EQ NE     
%left  LS LSEQ GTEQ GT 
%left  SHIFT_LEFT SHIFT_RIGHT
%left  PLUS MINUS     
%left  MUL
%right LOGICAL_NOT UNARY_MINUS UNARY_PLUS
%left  BRACKET_OPEN BRACKET_CLOSE PARA_OPEN PARA_CLOSE

//%type <sFunc> stmt_list
//%type <sFunc> stmt
%type <sFunc> function_parameter_list
%type <sFunc> function_declaration
%type <num> type
%type <sInt> function_parameter
%type <sInt> identifier_declaration
%type <sInt> expression
%type <sInt> primary
%%

program
     : program_element_list
     ;

program_element_list
     : program_element_list program_element 
     | program_element 
     ;

program_element
     : variable_declaration SEMICOLON
     | function_declaration SEMICOLON
     | function_definition
     | SEMICOLON
     ;
     
type
     : INT		{$$ = 1}
     | VOID		{$$ = 0}
     ;

variable_declaration
     : variable_declaration COMMA identifier_declaration
     | type identifier_declaration
     ;
	
identifier_declaration
     : identifier_declaration BRACKET_OPEN NUM BRACKET_CLOSE /*{TODO ARRAY}*/
     | ID {	if(existsInt($1)) {
			printf("ERROR! The variable %s was already declared.\n", $1);
			$$ = getInt($1);
		} else {
			$$ = putInt ($1, 0, 0);
		}
	     }
     ;
     
/*	Because of the new Grammar we don't have do delete the variable because functions are imediadly recongnised. Will stay here, if needed, for a few revesions..
function_signature
     : identifier_declaration PARA_OPEN {$$ = putFunc ($1->name, 1);deleteInt ($1->name)}
     ;*/

function_definition
     : type ID PARA_OPEN PARA_CLOSE BRACE_OPEN stmt_list BRACE_CLOSE
     | type ID PARA_OPEN function_parameter_list PARA_CLOSE BRACE_OPEN stmt_list BRACE_CLOSE
     ;

function_declaration
     : type ID PARA_OPEN PARA_CLOSE						{$$ = putFunc ($2, $1);}
     | type ID PARA_OPEN function_parameter_list PARA_CLOSE		{renameFunc ("-1temp", $2);setTypeP ($4, $1);}
     ;

function_parameter_list
     : function_parameter								{printf("choice1\n");$$ = putFunc ("-1temp", -1);setParamP ($$, $1);setScopeP ($1);}
     | function_parameter_list COMMA function_parameter		{
													printf("choice2\n");
													if(!existsFunc("-1temp"))
													{
														$$ = putFunc ("-1temp", -1);
														setParamP ($$, $3);
													} else {
														incParamCountP ($3);
													}
													setScopeP ($3);
												}
     ;
	
function_parameter
     : type identifier_declaration	 {$$ = $2; /*TODO: Error if void*/}
     ;

stmt_list
     : /* empty: epsilon */
     | stmt_list stmt
     ;

stmt
     : stmt_block
     | variable_declaration SEMICOLON
     | expression SEMICOLON
     | stmt_conditional
     | stmt_loop
     | RETURN expression SEMICOLON
     | RETURN SEMICOLON
     | SEMICOLON /* empty statement */
     ;

stmt_block
     : BRACE_OPEN stmt_list BRACE_CLOSE
     ;
	
stmt_conditional
     : IF PARA_OPEN expression PARA_CLOSE stmt
     | IF PARA_OPEN expression PARA_CLOSE stmt ELSE stmt
     ;
     
stmt_loop
     : WHILE PARA_OPEN expression PARA_CLOSE stmt
     | DO stmt WHILE PARA_OPEN expression PARA_CLOSE SEMICOLON
     ;
     
/*
 * The non-terminal 'expression' is one of the core statements containing all arithmetic, logical, comparison and
 * assignment operators.expression
 */									
expression								// 0 = "false", nonzero = "true"
     : expression ASSIGN expression				{addcodeass($1, $3);}
     | expression LOGICAL_OR expression			{$$ = addcodeopexp2(opLOGICAL_OR, $1, $3);}
     | expression LOGICAL_AND expression			{$$ = addcodeopexp2(opLOGICAL_AND, $1, $3);}
     | LOGICAL_NOT expression					{$$ = addcodeopexp1(opLOGICAL_NOT, $2);}
     | expression EQ expression					{$$ = addcodeopexp2(opEQ, $1, $3);}
     | expression NE expression					{$$ = addcodeopexp2(opNE, $1, $3);}
     | expression LS expression 					{$$ = addcodeopexp2(opLS, $1, $3);}
     | expression LSEQ expression 				{$$ = addcodeopexp2(opLSEQ, $1, $3);}
     | expression GTEQ expression 				{$$ = addcodeopexp2(opGTEQ, $1, $3);}
     | expression GT expression					{$$ = addcodeopexp2(opGT, $1, $3);}
     | expression PLUS expression				{$$ = addcodeopexp2(opADD, $1, $3);}
     | expression MINUS expression				{$$ = addcodeopexp2(opSUB, $1, $3);}
     | expression MUL expression				{$$ = addcodeopexp2(opMUL, $1, $3);}
     | MINUS expression %prec UNARY_MINUS		{$$ = addcodeopexp1(opMINUS, $2);}
     | ID BRACKET_OPEN primary BRACKET_CLOSE	{$$ = addcodeopexp2(opMEM_LD, $1, $3);}
     | PARA_OPEN expression PARA_CLOSE			{$$ = $2}
     | function_call
     | primary								{$$ = $1}
     ;

primary
     : NUM {$$ = putInt ("int", 0, $1)}
     | ID {	if(existsInt($1)) {
			$$ = getInt($1);
		} else {
			printf("ERROR! The variable %s was not declared. Line: %d Column: %d \n", $1, @1.first_line, @1.first_column);
			//We assume the variable should have been declared. so we declare it for the user...
			$$ = putInt ($1, 0, 0);
			//yyerror("syntax error");
		}
	  }
     ;

function_call
      : ID PARA_OPEN PARA_CLOSE
      | ID PARA_OPEN function_call_parameters PARA_CLOSE
      ;

function_call_parameters
     : function_call_parameters COMMA expression
     | expression
     ;

%%

void yyerror (const char *msg)
{
	printf("ERROR: %s\n", msg);
	//return 0;
}