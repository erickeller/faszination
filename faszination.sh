#!/bin/sh
# this script does grab the faszination wissen...

BASE_URL=http://www.br.de
INDEX_URL="${BASE_URL}/fernsehen/bayerisches-fernsehen/sendungen/faszination-wissen/faszination-wissen-a-z100.html"
TEMP_DIR=./temp
#VIDEO_DIR=./videos
VIDEO_DIR=/media/mariole/MyPassport/Fazination


WGET_OPTIONS="-nc --random-wait --no-cache --timeout=120"

# create temp directories
if [ ! -f ${TEMP_DIR} ]
then
	mkdir -p ${TEMP_DIR}
fi

if [ ! -f ${VIDEO_DIR} ]
then
	mkdir -p ${VIDEO_DIR}
fi


# grab the index url
# remove the exisiting index first
rm -f ${TEMP_DIR}/index
wget ${WGET_OPTIONS} ${INDEX_URL} -O ${TEMP_DIR}/index

# extract the episodes from the index
cat ${TEMP_DIR}/index | grep -e "<a href=\".*html\" id=.*" | sed -e "s/<a href=\"\(.*html\)\" id=.*/\1/g" > ${TEMP_DIR}/episode.txt

EPISODE_LIST=`cat ${TEMP_DIR}/episode.txt`
for episode in ${EPISODE_LIST}
do
	EPISODE_NAME=`basename ${episode} | sed -e "s/.html//g"`
	echo "Getting episode: ${EPISODE_NAME} ..."
	wget ${WGET_OPTIONS} ${BASE_URL}/${episode} -O ${TEMP_DIR}/${EPISODE_NAME} --quiet
	EPISODE_XML=`cat ${TEMP_DIR}/${EPISODE_NAME} | grep "\.xml" | sed -e "s/.*dataURL:'\(.*xml\)'.*/\1/g"`
	echo "${EPISODE_NAME} EPISODE_XML=${EPISODE_XML}"
	wget ${WGET_OPTIONS} ${BASE_URL}/${EPISODE_XML} -O ${TEMP_DIR}/${EPISODE_NAME}.xml --quiet
	SERVER_URL=`cat ${TEMP_DIR}/${EPISODE_NAME}.xml | grep "serverPrefix" | sed -e "s/<serverPrefix>\(.*\)<\/serverPrefix>/\1/g"`
	#FILE_URL=`cat ${TEMP_DIR}/${EPISODE_NAME}.xml | grep "<fileName>.*_B<" | sed -e "s/<fileName>\(.*\_B\)<.*/\1/g"`
	FILE_URL=`cat ${TEMP_DIR}/${EPISODE_NAME}.xml | grep  "<fileName>.*_B" | sed -e "s#<fileName>\(.*\)<.*#\1#g"`
    echo "${SERVER_URL}/${FILE_URL}"
	if [ ! -f ${VIDEO_DIR}/${EPISODE_NAME}.mp4 ]
	then
		echo "grabbing rtmpdump -r ${SERVER_URL} -y ${FILE_URL} -o ${VIDEO_DIR}/${EPISODE_NAME}.mp4"

		rtmpdump -r ${SERVER_URL} -y ${FILE_URL} -o ${VIDEO_DIR}/${EPISODE_NAME}.mp4
	fi
done

