#!/bin/bash
if [ -z "$1" ]
then
	echo "Pass a URL for a hugo deb file"
	exit 0
fi

cd /tmp
wget -o hugo.deb $1
sudo dpkg -i --force hugo.deb
rm hugo.deb

echo "* * * * * * SSH TO BLOG.AD.BRIGZZY.NET * * * * * *"
echo "* * * * * * SSH TO BLOG.AD.BRIGZZY.NET * * * * * *"
echo "* * * * * * SSH TO BLOG.AD.BRIGZZY.NET * * * * * *"
echo "* * * * * * SSH TO BLOG.AD.BRIGZZY.NET * * * * * *"
ssh root@blog "cd /tmp && \
wget -o hugo.deb $1 && \
dpkg -i --force hugo.deb && \
rm hugo.deb"
