%{
    #include<stdio.h>
    #include<string.h>
    #include <gmodule.h>
    #define BUFFER_LENGTH   2048
    void goThrough(FILE* w);
    void addword(char *w);
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
    GHashTable *words;
%}
%option main
%option yylineno
%option noyywrap

S   [\ \t]

%x PAGE QUOTE AUTOR PROVERBIO TITLE QUOTEPAGE PROBPAGE PROBOPTIONALS LINK
%%
    words = g_hash_table_new_full (g_str_hash, g_str_equal,g_free,NULL);
    f = stdout;
    qstats = fopen("QuoteStatistics.txt","w");
    pstats = fopen("ProbsStatistics.txt","w");
    q = fopen("quotes.txt","w");
    p = fopen("probs.txt","w");
    int adults = 0;
    char word[2500];
    int wordsize = 0;

\<page\>                    {
                                BEGIN(PAGE);
                                autor[0] = 0;
                                autorIndex = 0;
                                title[0] = 0;
                                titleidx = 0;
                                probs = 0;
                                quotes = 0;
                                proverbio = 0;
                            }

<PAGE>{
\<title\>       {   
                            
                            BEGIN(TITLE);
                        }
\<\/page\> {BEGIN(0);}
}


<TITLE>{
(\[|\])  {}
.               {
                    title[titleidx++] = yytext[0];
                }
\<\/title\>     {
                    title[titleidx]='\0';
                    if(!strncmp("Provérbios", title, strlen("Provérbios"))){
                        fprintf(p,"PROVERBIOS :%s: \n\n",title);
                        BEGIN(PROBPAGE);
                        proverbio=1;
                        adults = 0;
                    }
                    else{
                        BEGIN(QUOTEPAGE);
                    }
                }
}

<AUTOR>{
(\[|\])  {}                                                              
(\n|\|)                     {
                                BEGIN(QUOTEPAGE);
                                autor[autorIndex] = 0;
                                autorIndex = 0;
                            }
'''                         {
                                autor[autorIndex++] = '\"';
}                            
.                           {
                                autor[autorIndex++] = yytext[0];
                            }
}

<QUOTEPAGE>{
Nome{S}*={S}s*    {
                    BEGIN(AUTOR);
                }

Wikipedia{S}*={S}* { if(!autorIndex) BEGIN(AUTOR); }

\*{S}*(&quot;|“('')?|«){S}*    {
                            BEGIN(QUOTE);
                            if(!(proverbioOption && !proverbio)) {
                                fprintf(q,"“");
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
                    goThrough(qstats);
                }
            }
}

        
<QUOTE>{
\[ {}
\] {}
br&gt {}
(&quot;|”|\n|»)      {
                                BEGIN(QUOTEPAGE);
                                if(autor[0]) {
                                    fprintf(q, "” - %s\n", autor);
                                } else {
                                    fprintf(q, "”\n");
                                }
                                quotes++;
                                if (wordsize>0){
                                    word[wordsize]=0;
                                    addword(word);
                                    wordsize = 0;
                                }
                            }
                            
(\r|\ |\.|\,|\:|\“|\;|\!|\?|\)|\()                  {
                        if (wordsize>0){
                            word[wordsize]=0;
                            wordsize = 0;
                            //addword(word);
                        }
                        fprintf(q, "%s", yytext);
                    }

.                 {
                        if(yytext[0]!='\n')
                            word[wordsize++] = yytext[0]; 
                        fprintf(q, "%s", yytext);
                     }
'''                 {
                        fprintf(q, "\"");
                    }
\[\[               { BEGIN(LINK); }
}

<LINK>{
\]\]                {
                        BEGIN(QUOTE);
                    }
.                   {
                        fprintf(q, "%s", yytext);
                    }
[^\|(\]\])]*\|      {}
}

     
<PROBPAGE>{
\*\        {
                            probs++;
                            BEGIN(PROVERBIO);
}
.*(Adulterados|Adulteração):.*\n   {
        BEGIN(PROBOPTIONALS);
        fprintf(p,"\nAdulteraçoes:\n\t\t");
}
\**\  {}
\<\/page\> {
            BEGIN(0);
            if(probs || quotes){
                    fprintf(pstats,"Article:\"%s\"\n",title);
                    if(probs)
                        fprintf(pstats,"\tnº probs:%d\n",probs);
                    if(adults)
                        fprintf(pstats,"\tAdulteraçoes %d\n",adults);
                    goThrough(pstats);
            }
}
}
    
<PROVERBIO>{
\n {                            BEGIN(PROBPAGE);
                                if (wordsize>0){
                                    word[wordsize]=0;
                                    addword(word);
                                    wordsize = 0;
                                }
        }
(&lt|&lt;u&gt;|&lt;\/u&gt;|''|&quot;|\[|\]|\(.*\)) {}
(\r|\ |\.|\,|\:|\“|\;|\!|\?)                  {
                        if (wordsize>1){
                            word[wordsize]=0;
                            addword(word);
                            wordsize = 0;
                        }
                        fprintf(p, "%s", yytext);
                    }
. {
    if(yytext[0]!='\n')
        word[wordsize++] = yytext[0]; 
    fprintf(p,"%s",yytext);
  }
}


<PROBOPTIONALS>{
./\n((\*\*\*)\ |[^\*])  {fprintf(p,"%s",yytext);
          BEGIN(PROBPAGE);
         }

\n {fprintf(p,"\n\t\t");}
\*\*\* {adults++;}
(\[|\]|&quot;|\*|\(.*\)) {}
. {fprintf(p,"%s",yytext);}
}


<*>.|\n {}
%%


void addword(char *w){
    if (w[0]=='\0'|| w[0]=='\n') return;
    int size = strlen(w);
    if (w[size-1]=='\v') w[size-1]='\n';
    if(!g_hash_table_contains (words,w))
        g_hash_table_insert (words,strdup(w),(gpointer)1);
    else{
        int z = (int) g_hash_table_lookup (words,w);
        g_hash_table_insert (words,strdup(w),(gpointer)(z+1));
    }
}

void goThrough(FILE* w){
    GHashTableIter iter;
    gpointer key, value;
    g_hash_table_iter_init (&iter, words);
    int num = 0; char* wordMax;
    int total = 0;
    while (g_hash_table_iter_next (&iter, &key, &value))
    {
        // do something with key and value
        if(key!=NULL){
            total+=(int)value;
        }
        if(key!= NULL && (int)value>num){
           num = (int)value; 
           wordMax = (char*)key;
        }
    }
    if (num!=0)
        fprintf(w,"\tPalavra mais comum: \'%s\' aparece %d vezes\n\tNumero total de palavras: %d \n",wordMax,num,g_hash_table_size(words));
    g_hash_table_remove_all (words);
}
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