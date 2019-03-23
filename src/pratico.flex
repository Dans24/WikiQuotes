%{
    #include<stdio.h>
    #define BUFFER_LENGTH   2048
    FILE * f;
    char title[BUFFER_LENGTH];
    int titleidx = 0;
    int probs;
    int quotes;
    char autor[BUFFER_LENGTH];
    int autorIndex = 0;
    int proverbio = 0;
    int proverbioOption = 0;
%}
%option main
%option yylineno
%option noyywrap

%x PAGE QUOTE LINK AUTOR PROVERBIO
%%

    FILE * stats = fopen("Statistics.txt","w");
    f = stdout;
\<page\>                    {
                                BEGIN(PAGE);
                                autor[0] = 0;
                                title[0] = 0;
                                probs = 0;
                                quotes = 0;
                            }

<PAGE>{
\<\/page\>              {
                            BEGIN(0);
                            if(probs || quotes){
                                fprintf(stats,"Article:\"%s\"\n",title);
                                if(autor[0])
                                    fprintf(stats,"\tAuthor: %s\n",autor);
                                if(probs)
                                    fprintf(stats,"\tnº probs:%d\n",probs);
                                if(quotes)
                                    fprintf(stats,"\tnº quotes:%d\n",quotes);
                            }
                            probs = 0;
                            quotes = 0;
                            titleidx = 0;
                        }
\*\ *(&quot;|“|«)\ *    {
                            BEGIN(QUOTE);
                            if(!(proverbioOption && !proverbio)) {
                                fprintf(f,"“");
                            }
                        }
\<title\>       {   
                            titleidx = 0;
                            BEGIN(PROVERBIO);
                            proverbio = 1;
                        }
Nome\ *=\ *    {
                    BEGIN(AUTOR);
                    autorIndex = 0;
                }
}

<PROVERBIO>{
.               {
                    title[titleidx++] = yytext[0];
                }
\<\/title\>     {
                    BEGIN(PAGE);
                    title[titleidx]='\0';
                }
}

<AUTOR>{                                                              
\n                   {
                                BEGIN(PAGE);
                                autor[autorIndex] = 0;
                            }
.                    {
                                autor[autorIndex++] = yytext[0];
                            }
}


<QUOTE>{
\[\[                 {BEGIN(LINK);}
(&quot;|”|\n|»)      {
                                BEGIN(PAGE);
                                if(!(proverbioOption && !proverbio)) {
                                    if(autor[0]) {
                                        fprintf(f, "” - %s\n", autor);
                                    } else {
                                        fprintf(f, "”\n");
                                    }
                                    if(!strcmp(yytext,"&quot;"))
                                        probs++;    
                                    else
                                       quotes++;
                                }
                            }
.|\n                 {
                                if(!(proverbioOption && !proverbio)) {
                                    fprintf(f, "%s", yytext);
                                }
                            }
}


<LINK>{
\|.*\]\]              {BEGIN(QUOTE);}
.|\n                  {
                                if(!(proverbioOption && !proverbio)) {
                                    fprintf(f, "%s", yytext);
                                }
                            }
\]\]                  {BEGIN(QUOTE);}
}

<*>.|\n {}
%%

/*
int main(int argc, char* argv[]){
    char* option = 0;
    f = stdout; // Print in stdout by default
    yyin = stdin; // Read from stdin by default
    for(int i = 1; i < argc; i++) {
        if(argv[i][0] == '-'){
            option = &(argv[i][1]);
            continue;
        }
        if(strcmp(option, "o") != 0) {
            f = fopen (argv[i] , "w");
            printf("W:%s\n",argv[i]);
            continue;
        } else if(strcmp(option, "p") != 0) {
            proverbioOption = 1;
        }
        printf("R:%s\n",argv[i]);
        yyin = fopen(argv[i], "r");
    }
    yylex();
    return 0;
}
*/