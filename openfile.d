#!/usr/bin/sh

#
# Dini Alessio
# 07/06/2010
# openfile.d
# This script returns what process/command open a choosen file ( with absolute path )
#

usage() {
        echo "Usage:"
        echo
        echo "$0 [ -f file ] [-l] -h "
        echo
        echo "-f = file to check"
        echo "-l = see info about numeric codes"
        echo
        exit
}

if [ $# -eq 0 ]; then
        usage
fi

while getopts f:h:l value
do
        case $value in
        f)
                filename=$OPTARG;
                if [ ! -f $filename ]; then
                        echo
                        echo "The file $filename doesn't exists";
                        echo
                        exit;
                fi
                ;;
        l)
                echo
                echo " ____________________";
                echo "|      |             |";
                echo "| Code | Description |";
                echo "|______|_____________|";
                echo "|  0   |  read only  |";
                echo "| 769  | write only  |";
                echo "| 265  |   append    |";
                echo "|------|-------------|";
                echo
                echo
                if [ ! -n "$filename" ]; then
                        exit;
                fi
                ;;

        h)      usage
                ;;

        esac
        if [ $value != "f" ] && [ $value != "l" ] && [ $value != "h" ]; then
                usage
        fi
done


/usr/sbin/dtrace -n '

#pragma D option quiet

dtrace:::BEGIN
{
        FILE = "'$filename'";
        printf("\n\n%20s\t\t%6s\t\t%10s\n", "Command/Process", "PID", "Mode");
}

syscall::open*:entry
/copyinstr(arg0) == 'FILE'/
{
        self->mode = arg1;
        printf("%20s\t\t%6d\t\t%10d\n", execname, pid , self->mode);
        self->mode = 0;
}
'
