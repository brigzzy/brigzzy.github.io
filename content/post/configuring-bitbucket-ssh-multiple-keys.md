---
title: "Configuring Bitbucket SSH with Multiple Keys"
date: 2019-06-06T11:30:30-07:00
draft: false
---

If you use Bitbucket in multiple environments (for example home, and work), you may need to configure multiple SSH keys.  This is because once a key has been added to bitbucket (be it a work account, or a personal one), that key can no longer be used in any other Bitbucket account.  

The problem is that when you try and clone a repo via SSH, you may get a permission denied error when you connect to bitbucket.org with a valid key, but not a key that's valid for the repo you're trying to work with.  

To get around this, you can make an ssh config file that matches the host, username, and key you want to use.  

1. If you haven't already, generate your new SSH key that you want to use with Bitbucket:
```
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_bitbucket_personal
```
2. Add the public key to your Bitbucket account
3. Create a `~/.ssh/config` file
4. Add the following lines, substituting your values
```
Host bitbucket.org
User <someone>
Hostname bitbucket.org
IdentitiesOnly yes
IdentityFile ~/.ssh/id_bitbucket_personal
```
> Note that you can use any name in the User field.  You probably don't want to use git, if you're using that as your identity for another account.  

5. Now you can clone the repo from bitbucket.org, replacing the username git with the user you've configured in the ssh config file.  
```
git clone someone@bitbucket.org:myorg/repo.git
```
