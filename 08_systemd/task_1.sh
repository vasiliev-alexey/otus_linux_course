#!/bin/bash

echo '*** 1. Make config'

sudo cat << EOF > /etc/sysconfig/watchlog
# Config file for custom watch service
# Put it into /etc/sysconfig

# File for watching and word for analize

KEYWORD="ALERT"
LOGFILE=/var/log/veryimportant.log

EOF

echo '*** 2. Make sh service'

sudo cat << EOF > /opt/watchlog.sh
#!/bin/bash
KEYWORD=\$1
LOGFILE=\$2
DATE=\`date\`

if grep \$KEYWORD \$LOGFILE &> /dev/null
then
logger "\$DATE: Alarm detected"
else
exit 0
fi

EOF

chmod +x /opt/watchlog.sh

echo '*** 3. Make unit'

sudo cat << EOF > /etc/systemd/system/watchlog.service
[Unit]
Description=Alarm watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh \$KEYWORD \$LOGFILE

EOF

echo '*** 4. Make  timer'

sudo cat << EOF > /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target

EOF
echo '*** 5. Reload systemd config'
sudo systemctl daemon-reload
sudo systemctl start watchlog