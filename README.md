# **privoxy-pilot-macos**
Privoxy Pilot bash script and set of templates to better manage Privoxy on macOS. It is not connected to the Privoxy project.

<BR>

---

**Do not use anything from this project until this notice is removed!**

**This project is still in active development and is not ready for public use in any way, shape or form. It is made public for very limited testing only. If you do use it in its current state it will break things and when that happens you are on your own. Some of the options listed are not currently functioning.**

---

<BR>

This project is still in its beginnings. If you have a question please ask. If you are not comfortable working in the terminal than ask someone that is to help you.

[Privoxy](https://www.privoxy.org) is a wonderful project to which I'm in debt to its contributors. My project simply makes managing Privoxy's settings on macOS a bit easier. Features include:

- terminal based status panel with copious status details including:
  - up time
  - current filter group with their filters lists
  - past events
- detailed logging of events as transacted with Privoxy Pilot
- ability to easily create custom filter lists
- ability to easily create filter groups that contain multiple filter lists
- ability to easily switch between different filter groups from a single command line
- Uses Homebrew to make Privoxy installation very easy
- incorporates block lists from the [Block List Project](https://github.com/blocklistproject/Lists)

When stable I plan on using what has been done here and building the privoxy-pilot-ChromeOS project.

<BR>

## **Install Homebrew**

1. If not already installed, install the [Homebrew](https://en.wikipedia.org/wiki/Homebrew_(package_manager)) package manager:
   
   `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

<BR>

## **Install Privoxy**

1. Install Privoxy via brew:

    `brew install privoxy`

2. After installation start privoxy:

    `brew services start privoxy`

    If you see "Successfully started privoxy" then Privoxy was successfully installed.

3. If you don't see "Successfully started privoxy" the execute the following command: 

    `brew services start privoxy`

    If you see "Running: ✔" then Privoxy is running. If you see "Running: ✘" then something went wrong with the Homebrew installation. To get help refer to the Homebrew [documentation](https://docs.brew.sh/) and their [community group](https://github.com/orgs/Homebrew/discussions).

4. If you saw "Successfully started privoxy" setup your Mac to use the Privoxy proxy server by setting your proxy server to "127.0.0.1:8118" in Network settings. Test to ensure it works by going to "ads.com". If Privoxy is running and the correct proxy settings have been entered you will see a message in your browser window stating that access to that website has been blocked. If you see something else then something is wrong in either your proxy settings or Privoxy itself.

5. Finally shut down Privoxy:

    `brew services stop privoxy`

    You should see "==> Successfully stopped privoxy" confirming that Privoxy has been stopped.

<BR>

## **Configure Privoxy and install Privoxy Pilot**

Your choices are to either allow Privoxy to be accessible to clients on your local network or only by the Mac on which it is installed.
If you're unsure if your IP address is static then follow the instructions in "Configure Privoxy Pilot for single host use only" below "Configure Privoxy to be accessed by other local network clients and install Privoxy Pilot."

### **Install and configure Privoxy Pilot to be accessible by local network clients**

 It is recommended that Privoxy be accessible to clients on your local network **but only if you have a static IP address.** By allowing connections from clients on your local network other devices like phones, tablets and "smart tvs" can also take advantage of the features of Privoxy.

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/privoxy-shared-setup.sh)"`

### **Install and configure Privoxy Pilot for single host use only**

If you don't want to accept any connections from clients on your local network or don't have a static IP address this is the preferred installation and configuration.

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/privoxy-solo-setup.sh"`
    
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

1. Uncompress config.original:

    `gzip -d /usr/local/etc/privoxy/config.original.gz`

2. Edit config.original. Be careful as this is your original or "root" Privoxy config file. I'd suggest that all edits go at the top as that will make finding those edits at a later date.

    `nano /usr/local/etc/privoxy/config.original`

3. Compress config.original:

    `gzip /usr/local/etc/privoxy/config.original`

4. Delete config.bak and config. Running "ppilot.sh status" will recreate those files and display that action in the log section of status.

    `rm /usr/local/etc/privoxy/config.bak && rm /usr/local/etc/privoxy/config && /usr/local/etc/ppilot.sh status`

You should see "/usr/local/etc/privoxy/config.bak created" and "/usr/local/etc/privoxy/config created" in the log section of status.

<BR>

## **Questions**

**Q. Privoxy Pilot doesn't seem to be working. What can I do?**

1. Restore the original config file that was installed with Privoxy:
    
    `cp /usr/local/etc/privoxy/config.original /usr/local/etc/privoxy/config`

2. Start Privoxy from brew:

    `brew services start privoxy`

3. If you see "==> Successfully started privoxy" then it's possible that there was a problem in the previous config file.

4. On the Mac that is hosting Privoxy try going to "ads.com". You should see the Privoxy block page. This means Privoxy is working.
   
5. If you want to share your Privoxy connection then run:
   
    `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/privoxy-shared-reset.sh)"`

    Or for single host use only:

    `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/privoxy-solo-reset.sh)"`

6. Stop Privoxy via brew and start with Privoxy Pilot:

    `brew services stop privoxy && /usr/local/etc/privoxy/ppilot.sh`

7. That should fix the problem.

**Q. I did the "Install and configure Privoxy Pilot to be accessible by local network clients" but only the Mac hosting Privoxy can connect to the proxy server and no one from the local network can connect to the proxy server [hosted on the Mac].**

A. The install script detects your host's IP address and adds it to config but on the rare occasion that a host is using both their wireless and ethernet connections human intervention is required. Near the top of "/usr/local/etc/privoxy/config" you will see "listen-address" an IP address followed by ":8118" i.e.: "listen-address 192.168.1.2". Change the IP address to the IP of the connection in which client's can connect to your host.

The most common occurrence of this issue is when a Mac is being used a required of "forced" proxy server where local network clients connect to the Internet via the Mac's "share network" option and not directly to a dedicated router.

<BR>

## **FAQ**

**Q. Why did you create Privoxy Pilot?**

A. I, like many others, don't like being forced to just accept having our actions tracked by companies that refuse to give us the option to opt out of such tracking or advertising that also track us in much of the same way. 

While browser extensions are easier to install and use, anyone that's used them knows there's limits on what they can block. Also websites are becoming better at detecting such browser extensions and are either finding ways to avoid their blocking techniques or just blocking a person from accessing their website until they disable their ad blocking extension [for the host's website]. Privoxy avoids this issue by blocking intrusive websites before they are ever seen by your web browser. Proxy servers simply are much more effective at blocking unwanted web traffic and doing it in a way that's transparent to the website that is foisting those unwanted websites upon you.

It should be noted that Google Chrome's [manifest v3](https://developer.chrome.com/docs/extensions/mv3/intro/) extension standard will make it difficult for ad blockers to function as they currently do under the current manifest v2 standard which will make blocking ads in Chrome much more difficult. Manifest v3 was a needed revision for security reasons but it will also make life much more difficult for the developers of ad blocking extensions in Chrome. Unsurprising other major websites have been following Google's lead to block access to their websites if they detect you're using a ad blocking browser extension. For more on this issue I recommend reading "[Mozilla solves the Manifest V3 puzzle to save ad blockers from Chromapocalypse](https://adguard.com/en/blog/firefox-manifestv3-chrome-adblocking.html)"

"Chris Titus Tech" has a good [video](https://www.youtube.com/watch?v=oQL9dVsEXT0) explaining this issue of manifest v3 and how Google is also starting to block access to YouTube if you're using an ad blocking extension. He discusses [Pi-hole](https://github.com/pi-hole/pi-hole) that acts as a "[DNS sinkhole](https://en.wikipedia.org/wiki/DNS_sinkhole)" which is also a way to remove unwanted advertising and tracking websites from your web browser. Like Privoxy Pilot Pi-hole also uses Block List Project filters. 

I prefer using a proxy server method instead of a DNS sinkhole because it is easier for a host administrator to bypass if required, easier for an administrator to shut down if required and more difficult for users to bypass if their local network administrator has required them to use a proxy server but I highly recommend checking out their project as it has benefits over using a proxy server.

But why not just Privoxy instead of also adding Privoxy Pilot? Privoxy is an amazing program and I am in the debt of all those that contributed to it. In the interest of stability many times some features must be omitted. For example if Privoxy included support for the Block List Project, like Privoxy Pilot does, and for whatever reason their filter lists went offline then that would effect their entire user base. I agree with their choices and support them, and feel there's room to additions to their application for those that find a need for those additions.

**Q. Why is Privoxy Pilot a bash script and not a compiled application?**

A. Because a bash script worked well and I wanted as many people as possible to see the inner workings of what was being done. The more people that can see what's happening the more trust they'll have that nothing nefarious is happening. It will also make it much easier for others to  make feature requests, suggest bug fixes and even take what I've written and "roll it" into their own project.

**Q. Why not create multiple config files for different filter groups instead of using Privoxy Pilot to create and edit a new config file each time change are made?**

A. Then there would be multiple config files to deal with. By using Privoxy Pilot to copy the original config file and making the necessary changes there's only a single config file to modify.

**Q. Do you take donations?**

A. No but I ask that you consider donating to the [Privoxy(https://www.privoxy.org/faq/general.html#DONATE)] project as none of this would've been possible without their hard work and dedication to building an invaluable application. 





