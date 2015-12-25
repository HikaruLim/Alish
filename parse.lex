%{
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

//input related
extern char* g_ptr;
extern char* g_lim;

#undef YY_INPUT
#define YY_INPUT(b,r,ms)(r=my_yyinput(b,ms))
static int my_yyinput(char* buf,int max);

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
[^ \t\n]+    {add_arg(yytext);}
\n	    {exec_simple_cmd();reset_args();}
.	    ;
%%





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
    pid_t childpid;
    int status;
    if((childpid=fork())==-1)
    {
	perror("Failed to fork child");
	return;
    }
    
    if(childpid==0)
    {
//	printf("hehe\n");
	execvp(g_argv[0],g_argv);
	perror("Failed to execute command");
	exit(1);
    }
//    printf("wowowowowowowowo\n");
    waitpid(childpid,&status,0);
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































