#!/bin/bash
if [ -z "$1" ]
then
	echo "Set a commit message"
	exit 0
fi

hugo
git add .
git commit -m "$1"
git push

echo "* * * * * * SSH TO BLOG.AD.BRIGZZY.NET * * * * * *"
echo "* * * * * * SSH TO BLOG.AD.BRIGZZY.NET * * * * * *"
echo "* * * * * * SSH TO BLOG.AD.BRIGZZY.NET * * * * * *"
echo "* * * * * * SSH TO BLOG.AD.BRIGZZY.NET * * * * * *"
ssh root@blog "cd /var/www/html && bash pull.sh"
