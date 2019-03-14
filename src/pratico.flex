%{
    #include<stdio.h>
    int i = 0;
    FILE * f;
%}
%option main
%option yylineno
%option noyywrap

%x PAGE AUTHOR QUOTE LINK
%%
    f = fopen ("quotes.txt" , "w");
\<page\>                    {BEGIN(PAGE);}
<PAGE>\<\/page\>            {BEGIN(0);}
<PAGE>\*\ *(&quot;|“)       {BEGIN(QUOTE);}
<QUOTE>\[\[                 {BEGIN(LINK);}
<LINK>\|.*\]\]              {BEGIN(QUOTE);}
<LINK>.                     {
                                fprintf(f, "%s", yytext);
                            }
<LINK>\]\]                  {BEGIN(QUOTE);}
<QUOTE>(&quot;|”)           {
                                BEGIN(PAGE);
                                fprintf(f, "\n");
                            }
<QUOTE>.|\n                 {
                                fprintf(f, "%s", yytext);
                            }

<*>.|\n {}
%%
