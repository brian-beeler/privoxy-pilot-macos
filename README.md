
## **privoxy-pilot-macos**

Privoxy Pilot a collection of bash scripts and set of templates to better manage Privoxy on macOS. It is not connected to the Privoxy project.

This project is still in its early beginnings. If you have a question please [ask](https://github.com/brian-beeler/privoxy-pilot-macos/issues). If you are not comfortable working in the terminal than ask someone that is to help you. If you have an issue please post it to [issues](https://github.com/brian-beeler/privoxy-pilot-macos/issues).

[Privoxy](https://www.privoxy.org) is a wonderful project to which I'm in debt to its contributors. My project simply makes managing Privoxy's settings on macOS a bit easier. Features include:

- terminal based status panel with copious status details including:
  - up time
  - current filter group with their filters lists
  - past events
  
    ![ppilot status screen](https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot_status_screen.png)

- detailed logging of events as transacted with Privoxy Pilot
- ability to easily create custom filter lists
- ability to easily create filter groups that contain multiple filter lists
- ability to easily switch between different filter groups from a single command line
- Uses Homebrew to make Privoxy installation very easy
- incorporates block lists from the [Block List Project](https://github.com/blocklistproject/Lists)

When stable I plan on using what has been done here and building the privoxy-pilot-ChromeOS project.

#### **Updates**

- v1.01 (2023-06-11)
  - fixed formatting issues with lapsed time from PID and config creation dates to consistent HH:MM:SS.
  - fixed config date up time delay when config set <filter set> evoked.
  - renamed $bs in status() to $bsip (brew services info privoxy) to avoid confusion with bs() (brew services).
  - made lr() number of entries returned adjustable. i.e.: ppilot.sh status 20 returns last 20 log entries.
- Installer completely rewritten so instead of multiple files now there is only one for both install and repair, shared and solo.

<BR><HR>

### **Install Homebrew**

1. If not already installed, install the [Homebrew](https://en.wikipedia.org/wiki/Homebrew_(package_manager)) package manager:
   
   `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

<BR>

### **Install Privoxy**

1. Install Privoxy via brew:

    `brew install privoxy`

2. After installation start privoxy:

    `brew services start privoxy`

    If you see "Successfully started privoxy" then Privoxy was successfully installed.

3. If you don't see "Successfully started privoxy" the execute the following command: 

    `brew services start privoxy`

    If you see "Running: ✔" then Privoxy is running. If you see "Running: ✘" then something went wrong with the Homebrew installation. To get help refer to the Homebrew [documentation](https://docs.brew.sh/) and their [community group](https://github.com/orgs/Homebrew/discussions).

4. If you saw "Successfully started privoxy" setup your Mac to use the Privoxy proxy server by setting your proxy server to "127.0.0.1:8118" in Network settings. Test to ensure it works by going to "ads.com". If Privoxy is running and the correct proxy settings have been entered you will see a message in your browser window stating that access to that website has been blocked. If you see something else then something is wrong in either your proxy settings or Privoxy itself.

<BR>

### **Configure Privoxy and install Privoxy Pilot**

Run the command below to download the install script and install Privoxy Pilot:

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/brian-beeler/privoxy-pilot-macos/main/ppilot_setup_repair.sh)"`

When complete you should be presented with the status screen showing Privoxy running and the default filter set active.

<BR>

### **Options**

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

`/usr/local/etc/privoxy/ppilot.sh config <filter group>`

set a filter group

`/usr/local/etc/privoxy/ppilot.sh filter <name>`

create new filter list with <name>

`/usr/local/etc/privoxy/ppilot.sh log`

display log

<BR>

### **Creating a new filter list**

1. View a list of existing local filter groups and lists:  
   
    `/usr/local/etc/privoxy/ppilot.sh config list`
 
2. Create a new filter list named "work" [or whatever you want to name it]:

    `/usr/local/etc/privoxy/ppilot.sh filter work` 

3. Open your new list and follow the instructions in the comments of the file you just created on how to add the websites you wish to block.

<BR>

### **Create a new or edit an existing filter group**

1. Edit the config.mod file and follow the instructions in the comments: 
    
    `nano /usr/local/etc/privoxy/config.mod`


<BR>

### **Editing Privoxy options after Privoxy Pilot has been installed**

A quick explanation of the different configuration files:
- **config.original**: The original config file as shipped with Privoxy. This file is never changed.
- **config.bak**: a copy of config.original with a header showing where user changes can be made that survive updates
- **config**: a copy of config.bak that contains automated changes. Never edit this file as it's deleted on configuration updates.
- **config.mod**: contains filter groups with their respective lists.

Sometimes user changes need to be added to the Privoxy configuration. This must be done only in config.bak and never in config.original. 

If a mistake is made in editing config.bak that is causing Privoxy not to run and that mistake can not be tracked down simply delete config and config.bak then run:

    `/usr/local/etc/privoxy/ppilot.sh config set default`

This will cause Privoxy Pilot to rebuild config.bak from config.original and config, with all the automated additions, from config.bak. From there edit config.bak where noted near the top of config.bak.

If config.original is missing or damaged delete: config.original, config.bak and config. Then run:

    `gzip -dk /usr/local/etc/privoxy/config.original.gz && /usr/local/etc/privoxy/ppilot.sh config set default`

This will cause Privoxy Pilot to rebuild config.bak from the newly decompressed config.original. Then config, with all the automated additions, will be built with the automated additions from config.bak. From there edit config.bak where noted near the top of config.bak.

<BR>

### **Setting up and switching between the "default" to "distractions" filter groups**

The web is full of distractions that often take us away from more important tasks hence the reason for the "distractions" filter list and group which allows you to block sites that you don't want to see during working hours.

Instructions on how to add to the "distractions" filter list and setting up crontab to automatically switch back and forth between the "default" and "distractions" filter groups coming soon.

<BR>

### **Questions**

**Q. How do I set up Privoxy to be used by other computers or phones, smart tvs, etc?**

A. It's already done. Just go to the proxy settings on your other devices and add you Mac's IP address and port "8118". To find that address from the terminal:

    

    This will list the address or addresses Privoxy is listening to.

**Q. Privoxy doesn't seem to be working. What can I do?**

1. If you are using a Macbook and have switched to a new location, with a new IP address, there could be a conflict with another host. run:

    `/usr/local/etc/privoxy/ppilot.sh config set default`

    This will rebuild you config file with your current IP address.
   
2. Restore the original config file that was installed with Privoxy by deleting: config.original, config.bak and config. Then run:

    `gzip -dk /usr/local/etc/privoxy/config.original.gz && /usr/local/etc/privoxy/ppilot.sh config set default`

3. If that doesn't work run:
    
    `/usr/local/etc/privoxy/ppilot_setup_repair.sh`

    And follow the instructions to repair Privoxy.

4. Try resetting config to the original Privoxy version and start Privoxy from brew:

    `gzip -dk /usr/local/etc/privoxy/config.original.gz`

    `cp /usr/local/etc/privoxy/config.original /usr/local/etc/privoxy/config`

    `brew services start privoxy`

   If you see "==> Successfully started privoxy" then it's possible there was a problem in the previous config file. Run:

    `cp /usr/local/etc/privoxy/ppilot_setup_repair.sh`
   
   After restoring the original Privoxy configuration if you don't see "==> Successfully started privoxy" then something has gone wrong with Privoxy or Homebrew in its management of Privoxy. The first place to check is the Privoxy [documentation](https://www.privoxy.org/user-manual/index.html). Also refer to the Homebrew [documentation](https://docs.brew.sh/) and their [community group](https://github.com/orgs/Homebrew/discussions). 


<BR>

### **FAQ**

**Q. Why did you create Privoxy Pilot?**

A. I, like many others, don't like being forced to accept having our actions tracked by companies that refuse to give us the option to opt out of such tracking, or advertising that also tracks us in the same way. While web browsers do have an "opt out" option for receiving targeted advertising it is also optional for advertisers to honor that "opt out" request and to no one's surprise few honor that "opt out" request. There is simply too much profit in selling the details of our life, both online and offline, for amoral corporations to pass up. Privoxy and by extension Privoxy Pilot allows us to regain much of our privacy taken by those amoral corporations.

**Why browser extensions aren't the answer**

Browser extensions are easier to install and use, and anyone that's used them knows there's limits on what they can block. Also websites are becoming better at detecting such browser extensions and are either finding ways to avoid their blocking techniques or just blocking a person from accessing their website until they disable their ad blocking extension [for the host's website]. 

**Why browser extensions' days might be limited or at least their ability to block ads and trackers will be limited**

Google Chrome's [manifest v3](https://developer.chrome.com/docs/extensions/mv3/intro/) extension standard will make it difficult for ad blockers to function as they currently do under the current manifest v2 standard which will make blocking ads in Chrome much more difficult. Manifest v3 is a needed revision for security reasons but it will also make life much more difficult for the developers of ad blocking and privacy extensions in Chrome. Unsurprising other major websites have been following Google's lead to block access to their websites if they detect you're using a ad blocking browser extension. For more on this issue I recommend reading "[Mozilla solves the Manifest V3 puzzle to save ad blockers from Chromapocalypse](https://adguard.com/en/blog/firefox-manifestv3-chrome-adblocking.html)"

"Chris Titus Tech" has a good [video](https://www.youtube.com/watch?v=oQL9dVsEXT0) explaining this issue of manifest v3 and how Google is also starting to block access to YouTube if you're using an ad blocking extension. He discusses [Pi-hole](https://github.com/pi-hole/pi-hole) that acts as a "[DNS sinkhole](https://en.wikipedia.org/wiki/DNS_sinkhole)" which is also a way to remove unwanted advertising and tracking websites from your web browser. Like Privoxy Pilot Pi-hole also uses Block List Project filters. 

**Why proxy servers are the answer**

Privoxy avoids the issues faced by web browser ad blocking extensions by blocking intrusive websites before they are ever seen by your web browser. Proxy servers simply are much more effective at blocking unwanted web traffic than web browser extension and doing it in a way that's transparent to the website that is foisting those unwanted websites upon you.

I prefer using a proxy server method instead of a DNS sinkhole because it is easier for a host administrator to bypass if required, easier for an administrator to shut down if required and more difficult for users to bypass if their local network administrator has required them to use a proxy server but I highly recommend checking out their project as it has benefits over using a proxy server.

**Why not just use a VPN to block advertising and tracking websites?**

Remember the sentence "There is simply too much profit in selling the details of our life, both online and offline, for amoral corporations to pass up"? The same goes for VPN companies. Some are very good at protecting their users' privacy and some do little to protect their users' privacy and there's few options to sort out the good actors from the bad ones. On top of that you're paying for the privilege of the hope of privacy when in reality that hope might be misguided. VPNs have some important functions but depending on them to guarantee that tracking and advertising websites are not tracking you isn't one of them.

Privoxy and Privoxy Pilot are open source so there's no where to hide from the truth of what our software does. It's not possible for VPNs to have that level of transparently.

**But why not just use Privoxy instead of also adding Privoxy Pilot?**

Privoxy is an amazing program and I am in the debt of all those that contributed to it. In the interest of stability many times some features must be omitted. For example if Privoxy included support for the Block List Project, like Privoxy Pilot does, and for whatever reason BLP's filter lists went offline then that would effect their entire user base. I agree with Privoxy's choices and support them, and feel there's room to additions to their application for those that find a need for such additions.

**Q. Why is Privoxy Pilot a bash script and not a compiled application?**

A. Because a bash script worked well and I wanted as many people as possible to see the inner workings of what was being done. The more people that can see what's happening the more trust they'll have that nothing nefarious is happening. It will also make it much easier for others to  make feature requests, suggest bug fixes and even take what I've written and "roll it" into their own project.

**Q. Why not create multiple config files for different filter groups instead of using Privoxy Pilot to create and edit a new config file each time change are made?**

A. Then there would be multiple config files to deal with. By using Privoxy Pilot to copy the original config file and making the necessary changes there's only a single config file to modify.

**Q. Do you take donations?**

A. No but I ask that you consider donating to the [Privoxy](https://www.privoxy.org/faq/general.html#DONATE) project as none of this would've been possible without their hard work and dedication to building an invaluable application. 



