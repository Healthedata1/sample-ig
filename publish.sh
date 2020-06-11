#!/bin/bash
# exit when any command fails
set -e
while getopts dtwophbu: option
do
 case "${option}"
 in

 d) RECONFIG=1;;
 t) NA='N/A';;
 w) WATCH=1;;
 o) PUB=1;;
 p) UPDATE=1;;
 h) LOAD_HL7TEMPLATE=1;;
 b) LOAD_BASETEMPLATE=1;;
 u) TEST_TEMPLATE=$OPTARG;;
 esac
done
echo "================================================================="
echo === Publish $SOURCE IG!!! $(date -u) ===
echo see 'local workflow.md' file for how to use
echo "Optional Parameters"
echo '-d parameter for updating ig.json file from ig.yml config file (use when changing IG config parameters)= ' $RECONFIG
echo ' for -d parameter need python 3.7 and PyYAML, json and sys modules installed in your environment'
echo '-t parameter for no terminology server (run faster and offline)= ' $NA
echo '-w parameter for using watch on igpublisher from source default is off = ' $WATCH
echo '-o parameter for running previous version of the igpublisher= ' $PUB
echo '-p parameter for downloading latest version of the igpublisher from source = ' $UPDATE
echo '-h parameter for downloading HL7 ig template from source = ' $LOAD_HL7TEMPLATE
echo '-b parameter for downloading BASE ig template from source = ' $LOAD_BASETEMPLATE
echo '-u parameter for downloading test ig template from source or file= ' $TEST_TEMPLATE
echo ' current directory =' $PWD
echo "================================================================="
echo getting rid of .DS_Store files since they gum up the igpublisher....
find . -name '.DS_Store' -type f -delete
sleep 1
# git status

if [[ $RECONFIG ]]; then
echo "========================================================================"
echo "updating ig.json file from ig.yml config file"
echo "Python 3.7 and PyYAML, json and sys modules are required"
python3.7 -c 'import sys, yaml, json; json.dump(yaml.full_load(sys.stdin), sys.stdout, indent=4)' < input/data/ig.yml > input/ig.json
echo "========================================================================"
fi

if [[ $UPDATE ]]; then
echo "========================================================================"
echo "Downloading most recent publisher to:"
echo ~/Downloads/org.hl7.fhir.igpublisher.jar
echo "... it's ~100 MB, so this may take a bit"
echo "========================================================================"
mv ~/Downloads/org.hl7.fhir.igpublisher.jar ~/Downloads/org.hl7.fhir.igpublisher-old.jar \
|| mv ../../../Downloads/org.hl7.fhir.igpublisher.jar ../../../Downloads/org.hl7.fhir.igpublisher-old.jar
curl -L https://storage.googleapis.com/ig-build/org.hl7.fhir.publisher.jar \
-o ~/Downloads/org.hl7.fhir.igpublisher.jar \
|| curl -L https://storage.googleapis.com/ig-build/org.hl7.fhir.publisher.jar \
-o ../../../Downloads/org.hl7.fhir.igpublisher.jar
echo "===========================   Done  ===================================="
sleep 3
fi
# default is to use local my_framework as template
template=$PWD/my_framework
if [[ $LOAD_HL7TEMPLATE ]]; then
template=hl7.fhir.template
fi

if [[ $LOAD_BASETEMPLATE ]]; then
template=hl7.fhir.template
fi

if [[ $TEST_TEMPLATE ]]; then
template=$TEST_TEMPLATE
fi

echo "================================================================="
echo === load the hl7 template by setting $PWD/ig.ini ===
echo === template parameter to .................................... ===
echo === $template ===
echo "================================================================="
sed -i'.bak' -e "s|^template = .*|template = ${template}|" $PWD/ig.ini

path=~/Downloads/org.hl7.fhir.igpublisher.jar
if [[ $PUB ]]; then
path=~/Downloads/org.hl7.fhir.igpublisher-old.jar
fi

rm -rf output docs temp template

if [[ $WATCH ]]; then
  echo "================================================================="
  echo === run most recent version of the igpublisher with watch on ===
  echo "================================================================="
  java -jar ${path} -ig ig.ini -watch -tx $NA
else
  echo "================================================================="
  echo ===run igpublisher just once \(no watch option\)===
  echo "================================================================="
  echo java -jar ${path} -ig ig.ini -tx $NA
  java -jar ${path} -ig ig.ini -tx $NA
fi
