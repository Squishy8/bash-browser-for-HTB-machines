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
orangeColour="\e[38;2;255;165;0m\033[1m"
maroonColour="\e[38;2;128;0;0m\033[1m"


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
    echo -e "\t${turquoiseColour}i)${endColour} ${redColour}Search for a machine´s name by its IPv4 address.${endColour}"
    echo -e "\t${turquoiseColour}d)${endColour} ${redColour}Search machines by difficulty.${endColour}"
    echo -e "\t${turquoiseColour}m)${endColour} ${redColour}Search for a machine by name.${endColour}"
    echo -e "\t${turquoiseColour}o)${endColour} ${redColour}Search for machines by OS.${endColour}"
    echo -e "\t${turquoiseColour}s)${endColour} ${redColour}Search for machines by skills.${endColour}"
    echo -e "\t${turquoiseColour}h)${endColour} ${redColour}Show help panel.${endColour}"
    echo -e "\t${turquoiseColour}y)${endColour} ${redColour}Obtain YouTube link for the machine´s resolution.${endColour}"
    
}

function searchMachine(){
    machineName="$1" #machineName is the first argument given by the user after using -m command

    #The forward slashes in the awk command let us make an interval for selection. In this case, what is being done is a selection from "name: <name of teh machine>" to "resuelta:". Having to open and close the forward slashes and separate them by a coma.
    machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|resuelta|sku:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | while read -r line; do echo -en "${yellowColour}$(echo $line | awk '{print $1}')${endColour} "; echo -e "${turquoiseColour}$(echo $line | awk '{for (i=2; i<=NF; i++) printf $i " "}')${endColour}"; done)"

    if [ "$machineName_checker" ]; then
        echo -e "\n${yellowColour}[+]${endCOlour} ${grayColour}Listing machine properties of ${endColour}${blueColour}$machineName${endColour}${grayColour}:${endColour}"

        echo "$machineName_checker"
    else
        echo -e "\n${yellowColour}[!]${endColour} ${redColour}The machine you are looking for does not exist. Please enter a valid machine name.${endColour}\n"
    fi

    

    #Failed

    #cat bundle.js | awk "/name: \"$machineName\"    /,/resuelta:/" | grep -vE "id:|resuelta|sku:" |     tr -d '"' | tr -d ',' | sed 's/^ *//' | awk '{pr    intf "\033[1;33m" $1 "\033[0m"; for (i=2; i<=NF;     i++ ) { printf "\033[1;35m" $i "\033[0m"; print     "~"}; print " "} '



    #The sed command says this: "anything that starts (^) with a space and is followed by any content (*), must delete the spaces (//)"
}

function searchIP(){

    machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3| grep "name: " | awk 'NF{print $NF}' | tr -d '"|,')"

    if [ "$machineName" ]; then
        echo -e "\n${yellowColour}[+]${endColour} ${grayColour}$ipAddress -> ${endColour}${redColour}$machineName${endColour}\n"
    else
        echo -e "\n${yellowColour}[!]${endColour} ${redColour}The machine IPv4 address you are looking for does not exist. Please enter a valid machine IPv4.${endColour}\n"
    fi

    
}

function getYoutubeLink(){
    machineName="$1"

    youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta: /" | tr -d '"|,' | grep "youtube" | awk 'NF{print $NF}')"

    if [ $youtubeLink ]; then

    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}The tutorial for ${endColour}${blueColour}${machineName}${endColour} ${grayColour}can be found in the following link: ${endColour}${turquoiseColour}${youtubeLink}${endColour}\n"

    else

        echo -e "\n${yellowColour}[!]${endColour} ${redColour}The machine you are looking for does not exist. Please enter a valid machine name.${endColour}\n"
    fi

    
}

function getDifficulty(){
    difficulty="$1"

    resultChecker="$(cat bundle.js | sed 's/Fácil/Easy/' | sed 's/Media/Medium/' | sed 's/Difícil/Hard/' | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"|,' | column)"

    if [ "$resultChecker" ]; then

        if [ "$difficulty" == "Easy" ]; then
            colour=$greenColour

        elif [ "$difficulty" == "Medium" ]; then

            colour=$orangeColour
            
        elif [ "$difficulty" == "Hard" ]; then

            colour=$redColour
            
        elif [ "$difficulty" == "Insane" ]; then

            colour=$maroonColour
            
        fi

    echo -e "${colour}$(cat bundle.js | sed 's/Fácil/Easy/' | sed 's/Media/Medium/' | sed 's/Difícil/Hard/' | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"|,' | column)${endColour}"
        
    else
        echo -e "\n${yellowColour}[!]${endColour} ${redColour}The difficulty you are looking for does not exist. Please enter one of the following options.${endColour}\n"

        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Easy${endColour}\n"
        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Medium${endColour}\n"
        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Hard${endColour}\n"
        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Insane${endColour}\n"

    fi

}

function getOSMachines(){
    os="$1"

    osChecker="$(cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name: " | awk 'NF{print $NF}' | tr -d '"|,' | column)"

    if [ "$osChecker" ]; then

        cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name: " | awk 'NF{print $NF}' | tr -d '"|,' | column

    else

        echo -e "\n${yellowColour}[!]${endColour} ${redColour}The OS you are looking for does not exist. Please enter one of the following options.${endColour}\n"

        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Windows${endColour}\n"
        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Linux$\n"

    fi
}

function getOSDifficultyMachines(){
    difficulty="$1"
    os="$2"

    checkResults="$(cat bundle.js | sed 's/Fácil/Easy/' | sed 's/Media/Medium/' | sed 's/Difícil/Hard/' |grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"|,' | column)"

    if [ "$checkResults" ]; then

        cat bundle.js | sed 's/Fácil/Easy/' | sed 's/Media/Medium/' | sed 's/Difícil/Hard/' |grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"|,' | column

    else
        echo -e "\n${yellowColour}[!]${endColour} ${redColour}The OS or difficulty you are looking for does not exist.${endColour}\n"

        echo -e "\n${yellowColour}[+]${endColour} ${redColour}OS:${endColour}\n"

        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Windows${endColour}\n"
        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Linux$\n"

        echo -e "\n${yellowColour}[+]${endColour} ${redColour}Difficulty:${endColour}\n"

        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Easy${endColour}\n"
        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Medium${endColour}\n"
        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Hard${endColour}\n"
        echo -e "\t${yellowColour}[+]${endColour} ${greenColour}Insane${endColour}\n"
    fi
    
}

function getSkill(){
    skill="$1"

    resultChecker="$(cat bundle.js | grep "skills: " -B 6| grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d ',|"' | column)"

    if [ "$resultChecker" ]; then

        cat bundle.js | grep "skills: " -B 6| grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d ',|"' | column

    else

        echo -e "\n${yellowColour}[!]${endColour} ${redColour}There isn´t a machine that matches the skill ${endColour} ${blueColour}$skill${endColour}\n"

    fi

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

#Goobers
declare -i goober_difficulty=0
declare -i goober_os=0
#Goobers will help us use the -o and -d command in a oneliner while searching for the machines



while getopts "m:i:uhy:d:o:s:" arg; do #Commands with ":" after them indicate that they need to be passed an argument
    case $arg in
        m) machineName="$OPTARG"; let parameter_counter+=1;;
        u) let parameter_counter+=2;;
        h) let parameter_counter+=3;; #call function helpPanel
        i) ipAddress="$OPTARG"; let parameter_counter+=4;;
        y) machineName="$OPTARG";let parameter_counter+=5;;
        d) difficulty="$OPTARG"; goober_difficulty=1; let parameter_counter+=6;;
        o) os="$OPTARG"; goober_os=1; let parameter_counter+=7;;
        s) skill="$OPTARG"; let parameter_counter+=8;;
    esac
done

if [ $parameter_counter -eq 1 ]; then
    searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
    updateFiles
elif [ $parameter_counter -eq 3 ] || [ $parameter_counter -eq 0 ]; then
    helpPanel
elif [ $parameter_counter -eq 4 ]; then
    searchIP $ipAddress
elif [ $parameter_counter -eq 5 ]; then
    getYoutubeLink $machineName
elif [ $parameter_counter -eq 6 ]; then
    getDifficulty $difficulty
elif [ $parameter_counter -eq 7 ]; then
    getOSMachines $os
elif [ $goober_difficulty -eq 1 ] &&[ $goober_os -eq 1 ];then
    getOSDifficultyMachines $difficulty $os
elif [ $parameter_counter -eq 8 ]; then
    getSkill "$skill" #In this case, we put the variable that contains the arguments between double quotations because we will be taking arguments with spaces (Active Directory, SQL Injection, etc..). This will allow the function to interpret the entirety of the input without just taking the first argument (Activve, SQL, etc...)
else
    helpPanel
fi