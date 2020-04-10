#!/bin/bash

echo "Making directories"
DIR=project.$( date +%FT%H-%M )
mkdir $DIR
cd $DIR
mkdir Data
mkdir Korean_Codes

echo "Copying files"
cp -f ../*.R .
cp -f ../*.md .
cp -f ../*.Rproj .
cp -f ../Data/* ./Data
cp -f ../Korean_Codes/* ./Korean_Codes

# check we compile and run
echo "Run check code"
./extract.R

if [ $? -eq 0 ] 
then
    echo "Compile and run success!"
else
    echo "Compilation error! Exiting"
    exit 1
fi

cd ..

echo "Running tar $DIR"
tar -cf tar -cf ${DIR}.tar $DIR

echo "Running gzip ${DIR}.tar"
gzip ${DIR}.tar

echo "Removing build directory $DIR"
rm -rf $DIR

echo "Archived to ${DIR}.tar.gz"


