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

## **Installing Privoxy**

1. Install the [Homebrew](https://en.wikipedia.org/wiki/Homebrew_(package_manager)) package manager if not already installed:
   
   `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

2. Install Privoxy via brew:

    `brew install privoxy`

3. After installation start privoxy via brew:

    `brew start privoxy`

4. Execute the following command to see if Privoxy is running: 

    `brew services`

    You should see "privoxy started" which confirms it is running. If you see "privoxy error" either it did not start or possibly something went wrong during installation.

5. Before continuing setup your Mac to use the Privoxy proxy server by setting your proxy server to "127.0.0.1:8118" in Network settings. Test to ensure it works by going to "ads.com". If Privoxy is running and the correct proxy settings have been entered you will see a message in your browser window stating that access to that website has been blocked. If you see something else then something is wrong in your proxy settings or Privoxy itself.

<BR>

## **Installing Privoxy Pilot**

<BR>

### **Configure Privoxy Pilot to be accessed by other local network clients**

Recommended but only if you have a static IP address. By allowing connections from clients on your local network other devices like phones, tablets and "smart tvs" can also take advantage of the features of Privoxy.

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

    Or you can run the above commands from a single line:

    `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/privoxy-shared-setup.sh)"`


    "**config.original**" is your Privoxy config file as installed

    "**config**" is your Privoxy config file as installed with the addition of "listen-address" to allow for local area network connections
    
    "**config.bak**" is a backup of your modified config file
    
<BR>

### **Configure Privoxy Pilot for single host use only**

<BR>

If you don't want to accept any connections from your local network or don't have a static IP address:

1. Download the Privoxy script: 
   
    `curl -o "/usr/local/etc/privoxy/ppilot.sh" "https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot.sh"`

2. Set Privoxy Pilot to execute by: 
   
    `chmod og+x /usr/local/etc/privoxy/ppilot.sh`

3. Add some head room in config:

    `mv /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.original`

    `echo -e "\r\n\r\n# \r\n# \r\n# \r\n# \r\n" >> /usr/local/etc/privoxy/config`

    `echo -e /usr/local/etc/privoxy/config.original >> /usr/local/etc/privoxy/config`

    `cp /usr/local/etc/privoxy/config /usr/local/etc/privoxy/config.bak`

    Or you can run the above commands from a single line:

    `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/privoxy-solo-setup.sh"`

    "**config.original**" is your Privoxy config file as installed

    "**config**" is your Privoxy config file as installed with the addition of some header space

    "**config.bak**" is a backup of your modified config file
    
<BR>
  
### **Configure Privoxy Pilot for initial start**

<BR>

  1. Run Privoxy Pilot status: 
   
        `/usr/local/etc/privoxy/ppilot.sh status`

        This will perform a check for configuration files required to run and display what actions took place in the "log" section of status

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





