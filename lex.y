
%{
     #include <stdio.h>
     #include <string.h>

	int yylex();
	int yyerror(const char *msg);


     int EsteCorecta = 1;
	char msg[500];

	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
void showST();
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}
	void TVAR::showST(){
		printf("TABELA DE SIMBOLI!\n");
		TVAR* temp = TVAR::head;
		while(temp != NULL){
			printf("var = %s, val = %d\n",temp->nume, temp->valoare);
		temp = temp->next;
		}


	}
	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;
%}



%union { char* sir; int val;  }
%start prog

%token TOK_PROGRAM TOK_BEGIN TOK_END  TOK_INTEGER TOK_PLUS TOK_MINUS TOK_MULTIPLY TOK_DIVIDE TOK_LEFT TOK_RIGHT TOK_DECLARE TOK_WRITE TOK_ERROR TOK_READ TOK_FOR TOK_DO TOK_TO TOK_DOT TOK_COL TOK_ASSIGN TOK_SCOL TOK_VIRGULA 

%token <sir> TOK_VARIABLE
%token  <val> TOK_NUMBER 
%locations 

%type <sir> idlist


%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY  TOK_DIVIDE

%%


prog : TOK_PROGRAM progname TOK_DECLARE declist TOK_BEGIN stmtlist TOK_END TOK_DOT 
	{
		ts->showST();	
	}
;
progname : TOK_VARIABLE ; 


declist : dec | declist TOK_SCOL dec  ;


dec : idlist TOK_COL type {
	
char* token =strtok($1,", :\0");
	
	
     while(token!=NULL)
     {	 

		if(ts != NULL)
		{  

			if(ts->exists(token) == 0)
			{
                                 ts->add(token); 
					
			}
			else
			{ 
			    sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, token);
	    yyerror(msg);
	    YYERROR;
			}
		}
		else
		{
			 ts = new TVAR();
	 		 ts->add(token); 
		}
		
	token=strtok(NULL," ,\0\n");

	}
};

type : TOK_INTEGER ;


idlist : TOK_VARIABLE 
      |
       idlist TOK_VIRGULA TOK_VARIABLE 
{strcat($1,","); strcat($1,$3);}
;
     

stmtlist : stmt | stmtlist TOK_SCOL stmt ;

stmt : assign | read | write | for ;

assign : TOK_VARIABLE TOK_ASSIGN exp
{
	if(ts != NULL)
	{
	  if(ts->exists($1) == 1)
	  {
	    ts->setValue($1, 1);
	  }
	  else
	  {

	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;

	  }
	}
	else
	{

	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;

	}
} ;

exp : term 
      | exp TOK_PLUS term 

      | exp TOK_MINUS term 
;

term : factor 
	| term TOK_MULTIPLY factor 
        | term TOK_DIVIDE factor 
        /*   if($3 == 0) 
	  { 
	      sprintf(msg,"%d:%d Eroare semantica: Impartire la zero!", @1.first_line, @1.first_column);
	      yyerror(msg);
	      YYERROR;
	  } */
	  
 ;

factor : TOK_VARIABLE 
{
	if( ts != NULL)
	{
	   if(ts->exists($1)==0)
	     {
	
		 sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	  yyerror(msg);
	  YYERROR;

		}
	}
	else
	{

	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;

	
	}
	
}
	| TOK_NUMBER 
	| TOK_LEFT exp TOK_RIGHT ;

read : TOK_READ TOK_LEFT idlist TOK_RIGHT { 

char* token =strtok($3,",");
	
	
	while(token!=NULL)
        {

	if(ts != NULL)
	{
	  if(ts->exists(token) == 1)
	  {
	    ts->setValue($3,1);
	  }
	  else
	  {

	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, token);
	    yyerror(msg);
	    YYERROR;

	  }
	}
          else
	  {

	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, token);
	    yyerror(msg);
	    YYERROR;

	  }
	
	token=strtok(NULL,",");
      }
    

	}
;

write : TOK_WRITE TOK_LEFT idlist TOK_RIGHT
{
	
char* token =strtok($3,",");
	
	
	while(token!=NULL)
        {

	if(ts != NULL)
	{
	  if(ts->exists(token) == 1)
	  {
	    if(ts->getValue(token) == -1)
	    {

	      sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, token);
	      yyerror(msg);
	      YYERROR;

	    }
	   
	  }
	  else
	  {

	    sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, token);
	    yyerror(msg);
	    YYERROR;

	  }
	}
	else
	{

	  sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, token);
	  yyerror(msg);
	  YYERROR;

	}
	token=strtok(NULL,",");
      }
    

	}
;

for : TOK_FOR indexexp TOK_DO body ;

indexexp : TOK_VARIABLE TOK_ASSIGN exp TOK_TO exp
{                if(ts != NULL)
		{

			if(ts->exists($1))
			{

                             ts->setValue($1, 1);


			}
			else
			{
			    sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
			}
		}
		else
		{
                  	    sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, $1);
	    yyerror(msg);
	    YYERROR;
			 
		}  
};

body : stmt | TOK_BEGIN stmtlist TOK_END ;

%%

int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}	

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}














