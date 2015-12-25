#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

#define PROMPT_STRING "[Alish]zzz~ "
#define QUIT_STRING "exit\n"

static char inbuf[MAX_CANON];
char* g_ptr;
char* g_lim;

extern void yylex();

char prompt_head[30]=PROMPT_STRING;
char prompt_full[200]="<< ";
char hostname[50];
char path[100];
struct passwd* user_info;

int
main(void)
{

    user_info=getpwuid(getuid());
    //get the path    
    getcwd(path,sizeof(path));
   
    //get hostname
    gethostname(hostname,sizeof(hostname));

    strcat(prompt_full,user_info->pw_name);
    strcat(prompt_full,"@");
    strcat(prompt_full,hostname);
    strcat(prompt_full," ");
    strcat(prompt_full,path);
    strcat(prompt_full," >> ");

    if(strcmp(user_info->pw_name,"root")==0)
    {
	//prompt
    	strcat(prompt_full,strcat(prompt_head,"## "));
    }
    else{
	strcat(prompt_full,strcat(prompt_head,"$$ "));
    }
    for(;;)
    {
     //   if(fputs(PROMPT_STRING,stdout)==EOF)
	//    continue;
		

	if(fputs(prompt_full,stdout)==EOF)
            continue;
	if(fgets(inbuf,MAX_CANON,stdin)==NULL)
	    continue;
	if(strcmp(inbuf,QUIT_STRING)==0)
	    break;
	g_ptr=inbuf;
	g_lim=inbuf+strlen(inbuf);
	yylex();		
    }
    return 0;
}
