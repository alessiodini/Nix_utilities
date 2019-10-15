#!/usr/bin/bash

if [ $# -ne 2 ]; then
        echo
        echo "$0 accepts 2 argoments , for example $0 1 30"
        echo
        exit
fi

if [ $1 -lt $2 ]; then
        VAR=$1
        for i in $VAR;
        do
                while [ $VAR -le $2 ];
                do
                         echo $VAR
                         VAR=$(( $VAR + 1))
                done
        done
else
        echo
        echo "Errore: The first number must be lower than second"
        echo
        exit
fi
