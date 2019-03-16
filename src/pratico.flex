%{
    #include<stdio.h>
    #define BUFFER_LENGTH   2048
    FILE * f;
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
    f = stdout;
\<page\>                    {
                                BEGIN(PAGE);
                                autor[0] = 0;    
                            }
<PAGE>\<\/page\>            {BEGIN(0);}
<PAGE>\*\ *(&quot;|“|«)\ *    {
                                BEGIN(QUOTE);
                                if(!(proverbioOption && !proverbio)) {
                                    fprintf(f,"“");
                                }
                            }
<PAGE>\<title\>Provérbios   {
                                BEGIN(PROVERBIO);
                                proverbio = 1;
                            }
<PROVERBIO>\<\/title\>      {BEGIN(PAGE);}
<PAGE><text\ +xml:space=\"preserve\"\>\{\{Autor\n\ *\|\ *Nome\ *=\ *    {
                                                                            BEGIN(AUTOR);
                                                                            autorIndex = 0;
                                                                        }
<AUTOR>\n                   {
                                BEGIN(PAGE);
                                autor[autorIndex] = 0;
                            }
<AUTOR>.                    {
                                autor[autorIndex++] = yytext[0];
                            }
<QUOTE>\[\[                 {BEGIN(LINK);}
<QUOTE>(&quot;|”|\n|»)      {
                                BEGIN(PAGE);
                                if(!(proverbioOption && !proverbio)) {
                                    if(autor[0]) {
                                        fprintf(f, "” - %s\n", autor);
                                    } else {
                                        fprintf(f, "”\n");
                                    }
                                }
                            }
<QUOTE>.|\n                 {
                                if(!(proverbioOption && !proverbio)) {
                                    fprintf(f, "%s", yytext);
                                }
                            }
<LINK>\|.*\]\]              {BEGIN(QUOTE);}
<LINK>.|\n                  {
                                if(!(proverbioOption && !proverbio)) {
                                    fprintf(f, "%s", yytext);
                                }
                            }
<LINK>\]\]                  {BEGIN(QUOTE);}

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