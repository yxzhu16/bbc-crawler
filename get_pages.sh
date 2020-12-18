#!/bin/bash
if [ $# -ne 2 ]; 
    then echo "Please specify [language][input_file]"
    exit 1
fi
lg="$1"
src_file="$2"
catalog="catalog.txt"
pages_file="${lg}_pages_url.txt"
tmp_file="tmp.txt"
pattern="{n}"

while read url; do 
    if [[ $url =~ "{n}" ]]; then
	IFS=' ' read -ra my_array <<< "$url"
        num=${my_array[1]}
	u=${my_array[0]}
	for (( i=1; i<=$num; i++ ))
	  do
  	    echo ${u/$pattern/$i}
	  done
    else 
	echo $url
    fi 
done < $src_file > $catalog

while read url; do 
    lynx -dump -nonumbers -listonly $url | grep "www\.bbc\.com/$lg/[a-z\-]*[0-9]" | uniq 
done < $catalog > $tmp_file

cat $catalog $tmp_file | sort | uniq > $pages_file
rm $tmp_file
echo $(wc -l $pages_file) urls saved to $pages_file
echo "start crawling..."
grab-site --no-video -i $pages_file --level=1 --concurrency=4


