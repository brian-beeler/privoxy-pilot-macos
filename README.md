# **privoxy-pilot-macos**
Privoxy Pilot bash script and set of templates to better manage Privoxy on macOS. It is not connected to the Privoxy project.

<BR>

---

**Do not use anything from this project until this notice is removed!**

**This project is still in active development and is not ready for public use in any way, shape or form. It is made public for very limited testing only. If you do use it in its current state it will break things and when that happens you are on your own. Some of the options listed are not currently functioning.**

---

<BR>

This project is still in its beginnings. If you have a question please ask. If you are not comfortable working in the terminal than ask someone that is to help you.

Privoxy is a wonderful project to which I'm in debt to its contributors. My project simply makes managing Privoxy's settings on macOS a bit easier. Features include:

- terminal based status panel with copious status details including past events
- detailed logging of events as transacted with Privoxy Pilot
- ability to easily switch between different groups of filters from a single command line
- built to work with Privoxy installations done with brew
- incorporates block lists from the Block List Project.

When stable I plan on using what has been done here and building the privoxy-pilot-ChromeOS project.

<BR>

## **Install Homebrew**

1. If not already installed, install the [Homebrew](https://en.wikipedia.org/wiki/Homebrew_(package_manager)) package manager:
   
   `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`


## **Install Privoxy**

1. Install Privoxy via brew:

    `brew install privoxy`

2. After installation start privoxy:

    `/usr/local/opt/privoxy/sbin/privoxy /usr/local/etc/privoxy/config`

3. Execute the following command to see if Privoxy is running: 

    `ps xa | grep /usr/local/opt/privoxy/sbin/privoxy`

    You should see a process for "/usr/local/opt/privoxy/sbin/privoxy /usr/local/etc/privoxy/config" which confirms privoxy is running. If you do not see that process and only see "grep /usr/local/opt/privoxy/sbin/privoxy" privoxy did not start or possibly something went wrong during installation.

4. Setup your Mac to use the Privoxy proxy server by setting your proxy server to "127.0.0.1:8118" in Network settings. Test to ensure it works by going to "ads.com". If Privoxy is running and the correct proxy settings have been entered you will see a message in your browser window stating that access to that website has been blocked. If you see something else then something is wrong in either your proxy settings or Privoxy itself.

5. Finally shut down Privoxy:

    `pkill -f "/usr/local/opt/privoxy/sbin/privoxy"`

<BR>

## **Configure Privoxy and install Privoxy Pilot**

Your choices are to either allow Privoxy to be accessible to clients on your local network or only by the Mac on which it is installed.
If you're unsure if your IP address is static then follow the instructions in "Configure Privoxy Pilot for single host use only" below "Configure Privoxy to be accessed by other local network clients and install Privoxy Pilot."

### **Configure Privoxy to be accessed by other local network clients and install Privoxy Pilot**

 It is recommended that Privoxy be accessible to clients on your local network **but only if you have a static IP address.** By allowing connections from clients on your local network other devices like phones, tablets and "smart tvs" can also take advantage of the features of Privoxy.

#### **Automated installation**

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/privoxy-shared-setup.sh)"`

#### **Manual installation**

1. Download the Privoxy script: 
   
   `curl -o "/usr/local/etc/privoxy/ppilot.sh" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot.sh"`

2. Set Privoxy Pilot to execute by: 
   
   `chmod og+x /usr/local/etc/privoxy/ppilot.sh`

3. Add some head room to config and allow Privoxy to accept connections with clients on your local network:

    `mv /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.original`

    `echo -e "\r\n\r\n# \r\n# \r\n# \r\n# # allow privoxy to make connections with the local network" >> /usr/local/etc/privoxy/config`

    `echo -e "listen-address $(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')":8118 >> /usr/local/etc/privoxy/config`

    `echo -e "# \r\n# \r\n# \r\n# \r\n" >> /usr/local/etc/privoxy/config`

    `echo -e /usr/local/etc/privoxy/config.original >> /usr/local/etc/privoxy/config`

    `cp /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.bak`

    "**config.original**" is your Privoxy config file as installed

    "**config**" is your Privoxy config file as installed with the addition of "listen-address" to allow for local area network connections
    
    "**config.bak**" is a backup of your modified config file
    
<BR>

### **Configure Privoxy for single host use only and install Privoxy Pilot**

If you don't want to accept any connections from your local network or don't have a static IP address this is the preferred installation and configuration.

#### **Automated installation**

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/privoxy-solo-setup.sh"`

#### **Manual installation**

1. Download the Privoxy script: 
   
    `curl -o "/usr/local/etc/privoxy/ppilot.sh" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot.sh"`

2. Set Privoxy Pilot to execute by: 
   
    `chmod og+x /usr/local/etc/privoxy/ppilot.sh`

3. Add some head room in config:

    `mv /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.original`

    `echo -e "\r\n\r\n# \r\n# \r\n# \r\n# \r\n" >> /usr/local/etc/privoxy/config`

    `echo -e /usr/local/etc/privoxy/config.original >> /usr/local/etc/privoxy/config`

    `cp /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.bak`

    "**config.original**" is your Privoxy config file as installed

    "**config**" is your Privoxy config file as installed with the addition of some header space

    "**config.bak**" is a backup of your modified config file
    
<BR>
  
### **Configure Privoxy Pilot for initial start**

  1. Run Privoxy Pilot status: 
   
        `/usr/local/etc/privoxy/ppilot.sh status`

        This will perform a series of checks for the configuration files required to run and display what actions took place in the "log" section of status

   2. Run Privoxy Pilot to have the "default" filter list group activated:  
   
        `/usr/local/etc/privoxy/ppilot.sh config set default && /usr/local/etc/privoxy/ppilot.sh status`

        This will configure Privoxy to use the default filter set which consists of lists from Block List Project and a local file "/usr/local/etc/privoxy/filters/mylist" where you can add websites you want blocked. Locally created and managed filter lists are found in "/usr/local/etc/privoxy/filters". Block List Project filters are stored in "/usr/local/etc/privoxy/filters/blp" and should not be edited as they are automatically updated every week.

<BR>

## **Options**

`/usr/local/etc/privoxy/ppilot.sh`

display list of options

`/usr/local/etc/privoxy/ppilot.sh start`

start server

`/usr/local/etc/privoxy/ppilot.sh stop`

stop server

`/usr/local/etc/privoxy/ppilot.sh restart`

restart server

`/usr/local/etc/privoxy/ppilot.sh status`

status of server

`/usr/local/etc/privoxy/ppilot.sh config list`

list filter groups

`/usr/local/etc/privoxy/ppilot.sh filter <name>`

create new filter list with <name>

`/usr/local/etc/privoxy/ppilot.sh log`

display log

<BR>

## **Creating a new filter list**

1. View a list of existing local filter groups and lists: 
   
   `/usr/local/etc/privoxy/ppilot.sh config list` 
 
2. Create a new filter list named "work" [or whatever you want to name it]:

    `/usr/local/etc/privoxy/ppilot.sh filter work` 

3. Open your new list and follow the instructions in the comments of the file you just created on how to add the websites you wish to block.

<BR>

## **Create a new or edit an existing filter group**

   1. Edit the config.mod file and follow the instructions in the comments: 
    
        `nano /usr/local/etc/privoxy/config.mod`

<BR>

## **Editing Privoxy options after Privoxy Pilot has been run**

While not common editing the original Privoxy config file is sometimes necessary. It's important to edit the config file that was created on Privoxy's installation. The original config file untouched by Privoxy Pilot is stored in "/usr/local/etc/privoxy/config.original.gz". To edit:

Uncompress config.original:

`gzip -d /usr/local/etc/privoxy/config.original.gz`

Edit config.original. Be careful as this is your original or "root" Privoxy config file. I'd suggest that all edits go at the top as that will make finding those edits at a later date.

`nano /usr/local/etc/privoxy/config.original`

Compress config.original:

`gzip /usr/local/etc/privoxy/config.original`

Delete config.bak and config. Running "ppilot.sh status" will recreate those files and display that action in the log section of status.

`rm /usr/local/etc/privoxy/config.bak && rm /usr/local/etc/privoxy/config && /usr/local/etc/ppilot.sh status`

You should see "/usr/local/etc/privoxy/config.bak created" and "/usr/local/etc/privoxy/config created" in the log section of status.

<BR>

## **FAQ**

Q. Why did you create Privoxy Pilot?

A. I, like many others, don't like being forced to just accept having our actions tracked by companies that refuse to give us the option to opt out of such tracking or advertising that also track us in much of the same way. 

While browser extensions are easier to install and use, anyone that's used them knows there's limits on what they can block. Also websites are becoming better at detecting such browser extensions and are either finding ways to avoid their blocking techniques or just blocking a person from accessing their website until they disable their ad blocking extension [for the host's website]. Privoxy avoids this issue by blocking intrusive websites before they are ever seen by your web browser. Proxy servers simply are much more effective at blocking unwanted web traffic and doing it in a way that's transparent to the website that is foisting those unwanted websites upon you.

But why not just Privoxy instead of also adding Privoxy Pilot? Privoxy is an amazing program and I am in the debt of all those that contributed to it. In the interest of stability many times some features must be omitted. For example if Privoxy included support for the Block List Project, like Privoxy Pilot does, and for whatever reason their filter lists went offline then it would effect their entire user base. I agree with their choices and support them, and feel there's room to additions to their application for those that find a need for those additions.

Q. Why is Privoxy Pilot a bash script and not a compiled application?

A. Because a bash script worked well and I wanted as many people as possible to see the inner workings of what was being done. The more people that can see what's happening the more trust they'll have that nothing nefarious is happening. It will also make it much easier for others to  make feature requests, suggest bug fixes and even take what I've written and "roll it" into their own project.

Q. Why are you using "/usr/local/opt/privoxy/sbin/privoxy /usr/local/etc/privoxy/config" instead of "brew start privoxy" to start Privoxy?

A. The original plan was to use "brew start privoxy" et al but in testing I ran into problems with that and related commands failing. Even after repeated complete reinstalls of both Privoxy and finally both Privoxy and Homebrew the problem persisted. I don't if it was an issue on my Macs or not but "/usr/local/opt/privoxy/sbin/privoxy /usr/local/etc/privoxy/config" has always worked.

Q. Why not create multiple config files for different filter groups instead of using Privoxy Pilot to create and edit a new config file each time change are made?

A. Then there would be multiple config files to deal with. By using Privoxy Pilot to copy the original config file and making the necessary changes there's only a single config file to modify.


