#!/bin/bash
# My first script

echo -n "Build or Verify? (b/v): "
read answ

if [ "$answ" == "b" ]; then
	zip submission.zip summary.pdf summary.tex biblio.bib
	echo "Done. Ready to submit!";
	exit 1;
fi


echo -n "Did you check it on Windows? (y/n): "
read win

if [ "$win" != "y" ]; then
	echo "Build failed!";
  exit 1;
fi

echo -n "Did you check it on Overleaf? (y/n): "
read ovl

if [ "$ovl" != "y" ]; then
	echo "Build failed!";
  exit 1;
fi

zip submission.zip summary.pdf summary.tex biblio.bib

echo "Done. Ready to submit!";
