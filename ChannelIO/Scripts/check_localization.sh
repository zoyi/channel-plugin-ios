#!/bin/bash
[ -s intermediate.output ] && rm intermediate.output || touch intermediate.output
[ -s final.output ] && rm final.output || touch final.output
[ -s result.output ] && rm result.output || touch result.output

AUDITTYPE=${1:-"swift"}
REGEX=${2-"\.localized\(\"[a-zA-Z0-9_.]+\"\)"}
LOCALIZABLE=${3-"../Assets/en.lproj/Localizable.strings"} 
SEARCHFOLDER=${4-"../Source"}

echo "check type $AUDITTYPE, regex $REGEX and localization sample $LOCALIZABLE"

while IFS= read -d $'\0' -r file; do
	#sed -E "s/$REGEX/\1/g" $filename >> intermediate.output 
	awk 'match ($0, /\.localized\(\"[a-zA-Z0-9_.]+\"\)/){\
		print substr($0, RSTART+length(".localized("), RLENGTH-length(".localized()")),\
	   	FILENAME, NR }' $file >> intermediate.output
done < <(find $SEARCHFOLDER -iname "*.$AUDITTYPE" -print0)

#read output and separate key
while read name; do
    IFS=' ' read -r -a array <<< $name
	echo "${array[0]}" | sed -e 's/\.localized(//g' | sed -e 's/)//g' >> final.output
done < intermediate.output

#final contains all keys used in source code
#compare with .strings

while read key; do
	if grep -q $key $LOCALIZABLE; then
		var='found' # dummy
	else
		echo "$key not found" >> result.output
	fi
done < final.output

if [ -s result.output ]
then
	echo "There are some missing localizations"
	exit 1
else
	echo "Localization completed"
  rm final.output && rm intermediate.output && rm result.output
  exit 0	
fi
