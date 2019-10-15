#!/usr/bin/bash
#
# 11/11/2008 - Alessio Dini - Emanuel Gonzalez
#

usage() {
        echo "Usage:"
        echo
        echo $0 \{list\|all\}
        echo $0 list - for see total dimension of every path
        echo $0 all - for see free space
        echo
        exit
}

if [ $# -eq 1 ]; then
        arg=$1;
        work_dir="/var/tmp/chkdisks"
        mkdir -p $work_dir
        for path in `echo | format | awk '{ if ($2 ~ /^c/ ) print $2 }'`
        do
        sum=0;
        slice="${path}s2";
        sect=$(prtvtoc /dev/dsk/$slice | awk '{ if ($1 == 2) print $5 }');
        size_mb=$(echo ${sect}/2/1024 | bc);
        size_gb=$(echo ${sect}/2/1024/1024 | bc);
        if [ $1 == "list" ]; then
                echo "$path : ${size_gb}G"
        elif [ $1 == "all" ]; then
                prtvtoc /dev/dsk/$slice | egrep -v '^\*' | while read line
                do
                        part=$(echo $line | awk '{ print $1 }');
                        count=$(echo $line | awk '{ print $5 }');
                        mount=$(echo $line | awk '{ print $7 }');
                        if [ $part -eq 2 ]; then
                                echo $count > $work_dir/bck.$path
                        else
                                sum=$(($sum + $count));
                                echo $sum > $work_dir/sum.$path
                        fi
                done
                echo
                tot=$(cat $work_dir/bck.$path);
                busy=$(cat $work_dir/sum.$path);
                free=$(($tot - $busy));
                free=$(echo ${free}/2/1024 | bc);
                echo " Disk $path : ${size_gb}G"
                echo " Free Space : ${free}M"
        else
                usage
        fi
        done
        rm -rf $work_dir
else
        usage
fi
