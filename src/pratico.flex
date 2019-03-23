%{
    #include<stdio.h>
    #include<string.h>
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
    FILE * p;
    FILE * q;
    FILE * qstats;
    FILE * pstats;
%}
%option main
%option yylineno
%option noyywrap

%x PAGE QUOTE AUTOR PROVERBIO TITLE QUOTEPAGE PROBPAGE PROBOPTIONALS
%%
      
    f = stdout;
    qstats = fopen("QuoteStatistics.txt","w");
    pstats = fopen("ProbsStatistics.txt","w");
    q = fopen("quotes.txt","w");
    p = fopen("probs.txt","w");
    int altsAdults[2] ={0};
    int mode = 0;

\<page\>                    {
                                BEGIN(PAGE);
                                autor[0] = 0;
                                title[0] = 0;
                                probs = 0;
                                quotes = 0;
                                proverbio = 0;
                            }

<PAGE>{
\<title\>       {   
                            title[0] = 0;
                            titleidx = 0;
                            BEGIN(TITLE);
                        }

}


<TITLE>{
.               {
                    title[titleidx++] = yytext[0];
                }
\<\/title\>     {
                    title[titleidx]='\0';
                    if(!strncmp("Provérbios", title, strlen("Provérbios"))){
                        fprintf(p,"\nPROVERBIOS :%s -----------\n",title);
                        BEGIN(PROBPAGE);
                        proverbio=1;
                        altsAdults[0] = 0;
                        altsAdults[1] = 0;
                    }
                    else{
                        BEGIN(QUOTEPAGE);
                    }
                }
}

<AUTOR>{                                                              
\n                   {
                                BEGIN(QUOTEPAGE);
                                autor[autorIndex] = 0;
                            }
.                    {
                                autor[autorIndex++] = yytext[0];
                            }
}

<QUOTEPAGE>{
Nome\ *=\ *    {
                    BEGIN(AUTOR);
                    autorIndex = 0;
                }

\*\ *(&quot;|“|«)\ *    {
                            BEGIN(QUOTE);
                            if(!(proverbioOption && !proverbio)) {
                                fprintf(f,"“");
                            }
                        }
\<\/page\> {
                BEGIN(0);
                if(probs || quotes){
                    fprintf(qstats,"Article:\"%s\"\n",title);
                    if(autor[0])
                        fprintf(qstats,"\tAuthor: %s\n",autor);
                    if(quotes)
                        fprintf(qstats,"\tnº quotes:%d\n",quotes);
                }
            }
}

<QUOTE>{
\[\[ {}
\]\] {}
(&quot;|”|\n|»)      {
                                BEGIN(QUOTEPAGE);
                                if(autor[0]) {
                                    fprintf(f, "” - %s\n", autor);
                                } else {
                                    fprintf(f, "”\n");
                                }
                                quotes++;
                            }
.|\n                 {
                                    fprintf(f, "%s", yytext);
                     }
}

     
<PROBPAGE>{
\*\        {
                            probs++;
                            BEGIN(PROVERBIO);
    }
\<\/page\> {
            BEGIN(0);
            if(probs || quotes){
                    fprintf(pstats,"Article:\"%s\"\n",title);
                    if(probs)
                        fprintf(pstats,"\tnº probs:%d\n",probs);
                    if(altsAdults[0] || altsAdults[1])
                        fprintf(pstats,"\tAlternativas %d, Adulteraçoes %d\n",altsAdults[0],altsAdults[1]);
            }
}
}
    
<PROVERBIO>{
\n {BEGIN(PROBPAGE);}
.*'*Alternativos:.*\n  {
        BEGIN(PROBOPTIONALS);
        fprintf(p,"\nAlternativos\n\t\t");
        mode = 0;
    }
.*'*(Adulterados|Adulteração):.*\n   {
        BEGIN(PROBOPTIONALS);
        fprintf(p,"\nAdulteraçoes:\n\t\t");
        mode = 1;
    }
&lt;u&gt; {}
&lt;\/u&gt; {}
'' {}
&quot; {}
. {
    if(proverbio)
        fprintf(p,"%s",yytext);
    }
}

<PROBOPTIONALS>{
\n/\*\  {BEGIN(PROBPAGE);}
\*\* {BEGIN(PROBPAGE);}
\n {fprintf(p,"\n\t\t");}
(\[|\]|&quot;) {}
\*\*\* {altsAdults[mode]++;}
. {fprintf(p,"%s",yytext);}
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