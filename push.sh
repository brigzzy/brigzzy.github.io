#!/bin/bash
if [ -z "$1" ]
then
	echo "Set a commit message"
	exit 0
fi

hugo
git add .
git commit -m $1
git push

ssh brigzzy@blog "cd /var/www/html && bash pull.sh"
