#!/bin/bash

set -x # debug

prog=$(basename $0)

function print_usage() {
    echo "
create and print a label with arbitrary text, emphased as 3D object

see https://github.com/planraum/nameshield

Dependencies: 
 * openScad
 * jq (json handling in command line)
 * Droid Sans Mono font (must be recent enough)

Usage

  $prog -o OCTO -a APIKEY [-t TEMPLATE] [-p PROFILE] [-s SLICER] [-h]

  -a|--apikey APIKEY         Octoprint server API key

  -o|--octo OCTO             Octoprint server

  -t|--template TEMPLATE     Which openScad template to use. Default 
                               Anhaenger.template.scad

  -s|--slicer SLICER         Slicer to use on octoprint server. Default slic3r

  -p|--profile PROFILE       Slicer profile to use. Default prusa-0.15-pla-1.75

  -h|--help                  This help
"
}

while :
do
    case "$1" in
        -t|--template)
            template=$2
            shift
            shift
            ;;
        -o|--octo)
            octo=$2
            shift
            shift
            ;;
        -s|--slicer)
            slicer=$2
            shift
            shift
            ;;
        -p|--profile)
            profile=$2
            shift
            shift
            ;;
        -a|--apikey)
            apikey=$2
            shift
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        --) # end of all options
            shift
            break;
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *) # No more options
            break;
            ;;
    esac
done

apikey="${apikey:-NOT_SET}"
if [[ "$apikey" == "NOT_SET" ]]; then
    zenity --error \
           --title "$prog error" \
           --text "octopi API key not set. \nCheck $prog --help"
    exit 1
fi
template="${template:-Anhaenger.template.scad}"
profile="${profile:-prusa-0.15-pla-1.75}"
JQ=$(which jq)
if [[ $? -ne 0 ]]; then
    zenity --error \
           --title "$prog error" \
           --text "jq not found, try \nsudo apt-get install jq"
    exit 1
fi
octo="${octo:-NOT_SET}"
if [[ "$octo" == "NOT_SET" ]]; then
    zenity --error \
           --title "$prog error" \
           --text "octoprint server not set. \nCheck $prog --help"
    exit 1
fi
if [[ $octo != http* ]]; then
    octo="http://$octo"
fi


namelist="texts = ["
namecount=$#
outfile="/tmp/Anhaenger.scad"

input=$(zenity --forms --title="Erstelle Anhänger" --text="Gebe den Text für die Anhänger ein" \
   --add-entry="Erster Anhänger" \
   --add-entry="Zweiter Anhänger (optional)" \
   --add-entry="Dritter Anhänger (optional)" \
)

echo $input
IFS='|' read -a names <<< "$input"
echo "$names"

i=0;
for n in "${names[@]}"; do
    echo $n
    if [[ -z "$n" ]]; then
        continue
    fi
    i=$(($i+1))

    tc=$(echo "$n" | wc -m)
    if [[ $tc -gt 27 ]]; then
        echo "Warning: '$n' is to large"
    fi
    namelist="${namelist} \"$n\""
    # no comma on last element
    #if [[ $i -ne $namecount ]]; then
        namelist="${namelist}, "
    #fi
done
namelist="${namelist}];"
echo $namelist

STLFILE="/tmp/Anhanger.stl"
REMOTELOCATION="Anhanger.stl"

function dostuff() {
    echo "# erstelle template"
    echo "$namelist" > "$outfile"
    cat "$template" >> "$outfile"
    echo 5

    echo "# Erstelle 3D-Modelle"
    openscad -o /tmp/Anhaenger.stl /tmp/Anhaenger.scad
    echo 50

    echo "# Upload zum 3D-Drucker"
    curl -F "select=false" -F "print=false" -F "file=@/tmp/Anhaenger.stl" -H "X-Api-Key: $apikey" "${octo}/api/files/local"
    echo 70

    echo "# Warte bis Drucker bereit ist"
    curl -H "X-Api-Key: $apikey" -H "Content-Type: application/json" -X POST -d '{"command":"connect"}' "${octo}/api/connection"

    while true; do
        res=$(curl -H "X-Api-Key: $apikey" -H "Content-Type: applicaiton/json" -X GET "${octo}/api/connection")
        state=$(echo $res | jq -r ".current.state")
        if [[ "$state" == "Operational" ]]; then
            break;
        fi
        if [[ $cnt > 10 ]]; then
            echo "# ERROR: Printer $octo not ready"
    	    return 1
        fi
        sleep 1
        cnt=$(($cnt+1))
    done
    echo 80
    # slice and print Anhanger.stl
    
    echo "# Erstelle Druckerdateien und Starte Druck"
    curl -H "X-Api-Key: $apikey" -H "Content-Type: application/json" -X POST -d "{\"command\":\"slice\", \
    	\"select\":true,\
    	\"print\":true,\
    	\"slicer\":\"slic3r\",\
    	\"profile\":\"${PROFILE}\",\
    	\"gcode\":\"Anhaenger.gcode\"}" \
    	"${octo}/api/files/local/Anhaenger.stl"
    echo 95
    echo "# Warte bis drucker Fertig ist. Besuch $octo für Live-Ansicht"
    echo 100
}

dostuff | zenity --progress --title="Druckvorgang läuft" --percentage=0

exit 0

