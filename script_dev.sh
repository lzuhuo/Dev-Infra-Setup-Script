#!/bin/bash

PWD=$PWD
DIR_TMP="${PWD}/tmp_downloads"

#Check if directory to downloads exist
if [ -d "${DIR_TMP}" ] 
then
    echo "Directory ${DIR_TMP} exists." 
else
    echo "Directory ${DIR_TMP} does not exists. Creating now"
    mkdir $DIR_TMP
fi

#Check Url Requisitos para Downloads
filename='requirements.txt'
arrayFile=()
arrayUrl=()
arrayStatus=()
n=1

#Function to check URL Status if is OK ou broken
function check_url(){
  url=$1
  file=$2
  STATUS=$(curl -Is $url | head -1 | grep -o '[0-9][0-9][0-9]')
  if [ $STATUS -eq 200 ]
  then
     arrayFile+=("${file}")
     arrayUrl+=("${url}")
     echo "Adding ${file} file to array"
  else
     echo "false"
  fi
}

while read line; do
  IFS=' ' read var1 var2 <<< "${line}"
  check_url "${var2}" "${var1}"
  n=$((n+1))
done < $filename

## Download Files

function download_files(){
 FILE=$1
 URL=$2

 cd ${DIR_TMP}

 if test -f "${PWD}/${FILE}"
 then
    echo "$FILE exists."
 else
    echo "Download ${FILE}"
   wget "${URL}" -O "${FILE}"
 fi

}

i=0
len=${#arrayFile[@]}
while [ $i -lt $len ];
do
    download_files "${arrayFile[$i]}" "${arrayUrl[$i]}"
    let i++
done

## Install deb files

echo "Install deb files"
echo "Please, enter your password"
cd ${DIR_TMP}
sudo dpkg -i *.deb
sudo apt-get install -fy

## Install Git
sudo apt-get install git -y

##Clone Winbox Repo and Install
cd ..
git clone https://github.com/lzuhuo/winbox-installer.git
cd winbox-installer
sudo bash winbox-setup install


## Install Microsip via Wine
cd ${DIR_TMP}
echo "Instalando Microsip pela interface gráfica"
wine microsip.exe


##Instalando Postman 
echo "Instalando Postman via Snap"
snap install postman
