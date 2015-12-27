%{
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pwd.h>
//input related
extern char* g_ptr;
extern char* g_lim;

#undef YY_INPUT
#define YY_INPUT(b,r,ms)(r=my_yyinput(b,ms))
static int my_yyinput(char* buf,int max);
static int special_command();
enum cmds{xxx,cd}cmd;
extern struct passwd* user_info;
static void enum_cmd();

//cmd-arguments related
#define MAX_ARG_CNT 256

static char* g_argv[MAX_ARG_CNT];
static int g_argc=0;

static void add_arg(const char* xarg);
static void reset_args();

//cmd-handlers
static void exec_simple_cmd();
%}





%%
[^ \t\n]+   {add_arg(yytext);}
\n	    {exec_simple_cmd();reset_args();}
.	    ;
%%



static void
enum_cmd()
{
    if(strcmp(g_argv[0],"cd")==0)
	cmd=cd;
}

static int
special_command()
{
    enum_cmd();
    switch(cmd)
    { 
	case 1:    //1=>cd
	{
       	   // printf("cd OK!\n\n");
            char* cd_path = NULL;
            //"cd" == "cd ~"
            if(g_argv[1]==NULL)
            {
		char* t;
		char* arg;
		if((arg=malloc(strlen("~")+1))==NULL)
		{
		    perror("Failed to allocate memory");
		    return 1;
		}
		strcpy(arg,"~");
		if((t=malloc(strlen(arg)+1))==NULL)
    		{
       	            perror("Failed to allocate memory");
        	    return 1;
    		}
    		strcpy(t,arg);
   		g_argv[1]=t;
    		g_argc++;
    		g_argv[g_argc]=0;
            }

            if(strcmp(g_argv[1],"~")==0)
            {
                if((cd_path = malloc(strlen(user_info->pw_dir)+1))==NULL)
                {
       	            perror("Failed to allocate memory");
                    return 1;
		}
                strcpy(cd_path,user_info->pw_dir);
            }
            else
            {
                if((cd_path = malloc(strlen(g_argv[1])+1))==NULL)
                {
		    perror("Failed to allocate memory");
		    return 1;
                }
                strcpy(cd_path,g_argv[1]);
            }

            if(chdir(cd_path))
                printf("alish: cd: %s:%s\n",cd_path,strerror(errno));
            free(cd_path);
	 }
	
	 cmd=xxx;
	 return 1;
//	 break;

	 case 0:
	    return 0;
	    //break;
    }
    //return 1;
}

static void
add_arg(const char* arg)
{
    char* t;
    if((t=malloc(strlen(arg)+1))==NULL)
    {
	perror("Failed to allocate memory");
	return;
    }
    strcpy(t,arg);
    g_argv[g_argc]=t;
    g_argc++;
    g_argv[g_argc]=0;

}

static void
reset_args()
{
    int i;
    for(i=0;i<g_argc;i++)
    {
	free(g_argv[i]);
	g_argv[i]=0;
    }
    g_argc=0;
}

static void
exec_simple_cmd()
{
    //special command.--test
/*    if(strcmp(g_argv[0],"cd")==0)
    {
        printf("\n\ncommand cd is used\n\n");
        exit(1);
    }
*/

    //special command
    if(special_command()==0)  //return 1 means special_command() work OK.
    {
        pid_t childpid;
        int status;
        if((childpid=fork())==-1)
        {
	    perror("Failed to fork child");
	    return;
        }  
    
        if(childpid==0)
        {
	    execvp(g_argv[0],g_argv);
	    perror("Failed to execute command");
	    exit(1);
        }
        waitpid(childpid,&status,0);
}
}

static int
my_yyinput(char* buf,int max)
{
    int n;
    n=g_lim-g_ptr;
    if(n>max)
	n=max;

    if(n>0)
    {
	memcpy(buf,g_ptr,n);
	g_ptr+=n;
    }
    return n;
}































