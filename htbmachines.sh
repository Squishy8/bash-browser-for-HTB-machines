#!/bin/bash

#Colours from https://github.com/s4vitar/rpcenum
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Function that show the succesfull exit message 
function ctrl_c(){
    echo -e "\n\n${redColour}[!]Saliendo... ${endColour}\n"
    exit 1
}

#Function that shows a help panel
function helpPanel(){
    echo -e "\n[+] Uso:"
}

function searchMachine(){
    machineName="$1"

    echo "$machineName"
}

#Ctrl+c
trap ctrl_c INT

#Indicators
declare -i parameter_counter=0 #declare an integer



while getopts "m:h" arg; do
    case $arg in
        m) machineName=$OPTARG; let $parameter_counter += 1;;
        h) helpPanel;; #call function helpPanel 
    esac
done

if [ $parameter_counter -eq 1 ]; then
    searchMachine $machineName
else
    helpPanel

fi