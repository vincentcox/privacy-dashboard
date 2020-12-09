# Privacy dashboard
This project uses the [website-evidence-collector tool](https://github.com/EU-EDPS/website-evidence-collector) to do the hard work. That tool is an initiative of the European union. This dashboard script just puts everything together in a nice dashboard to get an overview of all your websites.

![DPO Holding fancy iPad Pro](resources_readme/DPO_holding_iPad_Pro_Mockup.jpg)

We made a small modification on this project to get a working Docker of this and use in this project. We therefore use [this forked project](https://github.com/vincentcox/website-evidence-collector). This is also discussed in their [issue tracker](https://github.com/EU-EDPS/website-evidence-collector/issues/42).

![Preview](resources_readme/preview.gif)

## Installation locally
Works on Mac and Linux.

Requirements:
- jq (`brew install jq` or `sudo apt install -y jq`)
- Docker (download from website or `sudo apt install -y docker.io`)

Get the docker image which this tool uses:
```bash
git clone https://github.com/vincentcox/website-evidence-collector # get the website-evidence-collector tool
cd website-evidence-collector
docker build -t website-evidence-collector . #build the image
cd ..
rm -rf website-evidence-collector # remove this, because the image will be kept
```


Download the script:
```bash
git clone https://github.com/vincentcox/privacy-dashboard
cd privacy-dashboard
```
Add your targets and remove the default example:
```bash
cd targets
rm example.com
nano domain.com #edit to the name you want
```

Execute the script:
```bash
bash script.sh
```

Open the `report.hmtl`.

## Installation on dedicated VPS/VM
Best is to spawn a VPS in the cloud and only allow your IP (or the IP-range of your organisation). Otherwise you can also do it internally.
The operating system that it's tested on is Ubuntu, but it might/probably work on other Linux distro's.

### Add SWAP
Because the tool is using Chrome, we obviously need enough memory.

If your machine already has SWAP, consider increasing it to at least 4G.


```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```
<i>Reference: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-20-04 </i>

### Webserver
We are going to use NGINX for this, but this can be every other webserver. No PHP is required because all files are static.

```bash
sudo apt install -y nginx
mkdir /var/www/html/app/
```

### Install Docker and get the docker image
```bash
sudo apt install -y docker.io   # install docker
sudo apt install -y git         # install Git
cd /tmp/
git clone https://github.com/vincentcox/website-evidence-collector # get the website-evidence-collector tool
cd website-evidence-collector
docker build -t website-evidence-collector . #build the image
cd ..
rm -rf website-evidence-collector # remove this, because the image will be kept
```

### Install this dashboard script
```bash
sudo su # become root
cd ~ # cd to root directory
git clone https://github.com/vincentcox/privacy-dashboard
cd privacy-dashboard
```

Add your targets and remove the default example:
```bash
cd targets
rm example.com
nano domain.com #edit to the name you want
```

All files in the folder `targets` will be iterated over.

### Configure the crontab
Go to the location of the script and use `pwd` to get the folder. Copy this.

Create a crontab as root:

```bash
sudo su
crontab -e
```

Use the following content:

```crontab
@reboot /location/of/your/script/directory/script_on_startup.sh
5 4 * * * /location/of/your/script/directory/script.sh
```

Save this.

If you don't reboot before running the script, run now:
```bash
script_on_startup.sh
```

And to test it:
```bash
script.sh
```
Surf to to the IP of your webserver.

You might need to add a redirection to `/app/index.html` either by javascript or in your NGINX configuration.

### Hardening
We recommend at least the following:
- automatic updates
- firewalling
- logrotation
- Using <b> and only allowing</b> SSH keys

#### Firewalling
We are going to use UFW.
```bash
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
```
<i>Reference: https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-20-04 </i>

#### Automatic updates
We will use unattended upgrades.
```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
# click "Yes"
```
Automatically reboot Ubuntu box WITHOUT CONFIRMATION for kernel updates:

edit `/etc/apt/apt.conf.d/50unattended-upgrades`
```
Unattended-Upgrade::Automatic-Reboot "true";
```

<i>Reference: https://www.cyberciti.biz/faq/set-up-automatic-unattended-updates-for-ubuntu-20-04/ </i>

#### Log rotation

#### Using and only allowing SSH keys
Username and password can be brute forced over SSH so we recommend to switch over to SSH keys instead of username+password authentication.

This is well explained in reference below.
<i>Reference: https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-20-04</i>


#### Extra mile
The points above are just the bare minimals to get it "pretty secure".

If you want to go the extra mile, you can use something like this: https://github.com/konstruktoid/hardening


# License
<b>European Union Public License 1.2</b>

As required by the license, the license (at the time of writing) is the same as the tool (website-evidence-collector) it uses:
https://github.com/EU-EDPS/website-evidence-collector/blob/fad1617e02b8ea3073132ba4821c64a891d25b61/LICENSE.txt

The changes can be viewed here:
https://github.com/EU-EDPS/website-evidence-collector/compare/master...vincentcox:master
