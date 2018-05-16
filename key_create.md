# How To Create Public and Private Keys

## Summary

While all of this information is readily available on the Internet, via an easy search, I got tired of always looking it up. So I am writing this doc to be an easy place for me to find the two methods that I use for this.  Please note this is NOT an exhaustive list of ways to create your keys.  This is just the two methods that I use.

## Create Key with PuTTYgen

I am a windows user, so this is the method I generally use.  However I am almost always using these keys for Linux based machines, so I wanted to point out how to not only use this key for PuTTY, but also with Linux based machines, like the Ubuntu "Bash" for Windows like I use on my machine.

### Install PuTTY and PuTTYgen

Of course in order to use this procedure, we will need to have PuTTY and PuTTYgen installed.  You can install it from [here](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html).  Do make sure you choose the .msi installer, as this will give you all of the tools, such as PuTTY and PuTTYgen ... Obviously install the msi when downloaded.

Now run PuTTYgen by:

    pressing the windows key, and typing puttygen

Click on the "Generate" button:

![alt text](/images/puttygen01.png)

Next, move your mouse around in the box, to create some randomness for the key.  Keep moving the mouse until the green bar reaches the end.

![alt text](/images/puttygen02.png)

Now we have a key, but we need to save them independantly, so we can put them werever we need them. Click on the "Save public key" button. Change to the directory where you want to store this public key, and then name the key something like "id_rsa.pub", and click save.

![alt text](/images/puttygen03.png)

Click on "Save private key".

![alt](/images/puttygen04.png)

You will recieve a warning, click yes since we are not setting a passpharse for additional protection ...

![alt](/images/puttygen05.png)

Select the directoy to store the private key in, and name it something like "id_rsa.ppk", and click save.  This key is a .ppk key that can be used with PuTTY.  But the key is not ready to be used with Linux based machines.

So we will create an OpenSSH version of the private key.  Click on "Conversions" and then "Export OpenSSH key".

![alt](/images/puttygen06.png)

Again say yes to the warning.

![alt](/images/puttygen05.png)

Finally select the directory where to save the private key, and name they key something like "id_rsa".

You now have all of the keys you need to work with both windows PuTTY, and Linux based SSH systems.

## Create Key with OpenSSH

Since I do indeed work with a lot of Linux based machines I also need to use this method from time to time as well.  Here are the steps, so I don't have to go and look them up again.

Open a Linux window, and type the following:

    ssh-keygen -f /directory/where/you/want/the/keys

When you are done, you will have a private key, and a public key that can be used on Linux based machines.  However you might still want to use PuTTY, so you also want a .ppk version of the private key.

Use PuTTYgen to covert the id_rsa private key, to a .ppk, by simply opening PuTTYgen, and clicking on the load button.

![alt](/images/puttygen07.png)

In the "Load private key" box, make sure select "All Files":

![alt](/images/puttygen08.png)

Select the file name like "id_rsa", and click the "Open" button. Click "OK" on the PuTTYgen Notice window.

![alt](/images/puttygen09.png)

Now save the private key and name it something like "id_rsa.ppk"

![alt](/images/puttygen04.png)

![alt](/images/puttygen05.png)

You now have the same set of keys as above.  Happy SSH'ing!