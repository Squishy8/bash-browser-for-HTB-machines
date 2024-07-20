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
    tput cnorm && exit 1 #Get cursor back every time CTRL+C is typed, no matter what.
}

#Ctrl+c
trap ctrl_c INT

#Global variables
main_url="https://htbmachines.github.io/bundle.js"

#Function that shows a help panel
function helpPanel(){
    echo -e "\n${yellowColour}[+]${endColour} Use:"
    echo -e "\t${turquoiseColour}u)${endColour} ${redColour}Download or update necesary files.${endColour}"
    echo -e "\t${turquoiseColour}m)${endColour} ${redColour}Search for a machine by name.${endColour}"
    echo -e "\t${turquoiseColour}h)${endColour} ${redColour}Show help panel.${endColour}"
    echo -e "\t${turquoiseColour}i)${endColour} ${redColour}Search name of machine by its IPv4 address.${endColour}"
}

function searchMachine(){
    machineName="$1"

    echo -e "\n${yellowColour}[+]${endCOlour} ${grayColour}Listing machine properties of ${endColour}${blueColour}$machineName${endColour}${grayColour}:${endColour}"

    #The forward slashes in the awk command let us make an interval for selection. In this case, what is being done is a selection from "name: <name of teh machine>" to "resuelta:". Having to open and close the forward slashes and separate them by a coma.
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|resuelta|sku:" |tr -d '"' |tr -d ',' | sed 's/^ *//' | while read line; do echo -en ${yellowColour}$(echo $line |awk '{print $1}')${endColour}; echo -e ${turquoiseColour}$(echo $line | awk '{for (i=2; i<=NF; i++) print $i}')${endColour}; done


    #Failed

    #cat bundle.js | awk "/name: \"$machineName\"    /,/resuelta:/" | grep -vE "id:|resuelta|sku:" |     tr -d '"' | tr -d ',' | sed 's/^ *//' | awk '{pr    intf "\033[1;33m" $1 "\033[0m"; for (i=2; i<=NF;     i++ ) { printf "\033[1;35m" $i "\033[0m"; print     "~"}; print " "} '



    #The sed command says this: "anything that starts (^) with a space and is followed by any content (*), must delete the spaces (//)"
}

function updateFiles(){
    #Validations to check the existance of the "bundle.js" in the current directory
    if [ ! -f bundle.js ]; then
        echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Downloading necessary files...${endColour}"
        curl -s -X GET $main_url > bundle.js #Explicitly make a GET petition in silent format, asking for the updated list of HTB machines and direct the output to the "bundle.js" file that was created.

        js-beautify bundle.js | sponge bundle.js #Using js-beautify, make the previous otput better looking and understandable.
        echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Files downloaded successfully :)${endColour}"
    else #If the "bundle.js" file already exists, then the same petition will be made to main_url, creating a new file "bundle_temp.js" that will be compared with the original file using md5. In case the hashes are the same, "bundle_temp.js" will be removed, but if the hashes are different then "bundle.js" will be removed and "bundle_temp.js" will be renamed as "bundle.js"
        echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Checking for updates...${endColour}"
        curl -s -X GET $main_url > bundle_temp.js

        js-beautify bundle_temp.js | sponge bundle_temp.js

        md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
        md5_original_value=$(md5sum bundle.js | awk '{print $1}')

        if [ "$md5_original_value" == "$md5_temp_value" ]; then
            echo -e "\n${yellowColour}[+]${endColour} ${grayColour}No updates detected. Files are up to date.${endColour}"
            rm bundle_temp.js
        else
            echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Updates detected${endColour}"
            echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Updating files...${endColour}"
            sleep 2
            rm bundle.js && mv bundle_temp.js bundle.js
            echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Files updated successfully :)${endColour}"
        fi
    fi
    tput cnorm
    
}

#Indicators
declare -i parameter_counter=0 #declare an integer and set it to zero to verify amount of arguments passed by the user



while getopts "m:uh" arg; do #Commands with ":" after them indicate that they need to be passed an argument
    case $arg in
        m) machineName=$OPTARG; let parameter_counter+=1;;
        u) let parameter_counter+=2;;
        h) let parameter_counter+=3;; #call function helpPanel 
    esac
done

if [ $parameter_counter -eq 1 ]; then
    searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
    updateFiles
elif [ $parameter_counter -eq 3 ] || [ $parameter_counter -eq 0 ]; then
    helpPanel

fi