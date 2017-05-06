#!/bin/bash

FILES=~/Documents/IFADVcorpus/video/speaker_A/*.avi
source="http://www.fon.hum.uva.nl/IFA-SpokenLanguageCorpora/IFADVcorpus/Compressed/"
ext=".avi"

for f in $FILES;do
	file=${f##*/}
	name=${file%.avi}
	name_b=$(python getNameB.py $name)
	url=$source$name_b$ext
	echo $url
	wget --directory-prefix=/Users/tim/Documents/IFADVcorpus/video/speaker_B/ $url
done 
