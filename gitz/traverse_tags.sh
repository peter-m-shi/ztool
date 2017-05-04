#!/bin/sh

git tag > tag_list.txt

while read line; 
do
	echo $line;
	git clean . -df
	git checkout .
	git checkout $line
	find . -name "*.a" > $HOME/Downloads/result/$line.a.txt
	find . -name "*.framework" >> $HOME/Downloads/result/$line.f.txt
	find . -name "*.m" >> $HOME/Downloads/result/$line.m.txt
	find . -name "*.h" >> $HOME/Downloads/result/$line.h.txt
done < tag_list.txt