
%{
	#include "lex.tab.h"
       
	int lineNo = 1;
	int colNo = 1;
%}

%%
"PROGRAM"      			{ colNo+=7; return TOK_PROGRAM; }       
"BEGIN"	       			{ colNo+=5; return TOK_BEGIN; }
"END"          			{ colNo+=3; return TOK_END; }
"."                             { colNo+=1; return TOK_DOT;}
":"            			{ colNo+=1; return TOK_COL; } 
"INTEGER"      			{ colNo+=7; return TOK_INTEGER; }
"+"				{ colNo+=1; return TOK_PLUS; }
"-"				{ colNo+=1; return TOK_MINUS; }
"*"				{ colNo+=1; return TOK_MULTIPLY; }
"DIV"				{ colNo+=1; return TOK_DIVIDE; }
"("				{ colNo+=1; return TOK_LEFT; }
")"				{ colNo+=1; return TOK_RIGHT; }
";"				{ colNo+=1; return TOK_SCOL; }
"VAR"			 	{ colNo+=3; return TOK_DECLARE; }
"WRITE"				{ colNo+=5; return TOK_WRITE; }
","                             { colNo++;  return TOK_VIRGULA; }
":="				{ colNo+=2; return TOK_ASSIGN; } 
"READ"				{ colNo+=4; return TOK_READ; }
"FOR"				{ colNo+=3; return TOK_FOR; }
"DO" 				{ colNo+=2; return TOK_DO; }
"TO"      			{ colNo+=2; return TOK_TO; }
([+-]?)0|[1-9][0-9]*	{ yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.val = atoi(yytext); return TOK_NUMBER; }
[a-zA-Z][a-zA-Z0-9_]* { yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen(yytext); yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir,yytext); return TOK_VARIABLE;}
[ ]				{colNo++; }
\r\n				{ lineNo++; colNo=1; }
\n				{ lineNo++; colNo=1; }
.				{ colNo++;  return TOK_ERROR; }
%%



