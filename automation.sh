myname=Niranjan
s3_bucket=upgrad-$(echo "$myname" | tr '[A-Z]' '[a-z]')
timestamp=$(date '+%d%m%Y-%H%M%S')
servName=apache2

sudo apt update -y

if [[ -z $(dpkg -l | grep $servName) ]]
then
	echo "===> installing $servName"
	sudo apt install $servName -y
fi

if [[ $(systemctl is-active $servName) != 'active' ]]
then
	echo "===> starting $servName"
	sudo systemctl start $servName
fi


if [[ $(systemctl is-enabled $servName) != 'enabled' ]]
then
	echo "===> enabling $servName"
	sudo systemctl enable $servName
fi


if [[ ! -e /var/www/html/inventory.html ]]
then
	echo "===> creating html file"
	touch /var/www/html/inventory.html
	echo "<pre>Log_Type    Time_Created     Type  Size<pre>" > /var/www/html/inventory.html

fi

if [[ ! -e /etc/cron.d/automation ]]
then
        echo "===> creating cron file"
        touch /etc/cron.d/automation 
        echo "* * * * * root /bin/bash /root/Automation_Project/automation.sh" > /etc/cron.d/automation
	crontab /etc/cron.d/automation

fi




sudo apt install awscli -y


cd /var/log/$servName/
tar cvf  /tmp/$myname-httpd-logs-$timestamp.tar *.log

aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

echo "<pre>httpd-logs  $timestamp  tar   $(ls -ltrh /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $5}')<pre>" >> /var/www/html/inventory.html

cd
