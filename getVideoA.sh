#!/bin/bash

FILES=~/Documents/IFADVcorpus/EAF/*.EAF
source="http://www.fon.hum.uva.nl/IFA-SpokenLanguageCorpora/IFADVcorpus/Compressed/"
ext=".avi"

for f in $FILES;do
	file=${f##*/}
	name=${file%.EAF}
	url=$source$name$ext
	wget --directory-prefix=/Users/tim/Documents/IFADVcorpus/video/ $url
done 
