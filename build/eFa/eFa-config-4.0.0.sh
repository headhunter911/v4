#!/bin/sh
#-----------------------------------------------------------------------------#
# eFa 4.0.0 initial service-configuration script
#-----------------------------------------------------------------------------#
# Copyright (C) 2013~2017 https://efa-project.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Source the settings file
#-----------------------------------------------------------------------------#
source /usr/src/eFa/eFa-settings.inc
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Start configuration of services
#-----------------------------------------------------------------------------#

# pre-create the EFA backup directory
mkdir -p /var/eFa/backup
mkdir -p /var/eFa/backup/KAM

# pre-create the EFA lib directory
mkdir -p /var/eFa/lib
mkdir -p /var/eFa/lib/eFa-Configure

# pre-create the EFA Trusted Networks Config
touch /etc/sysconfig/eFa_trusted_networks

# write issue file
cat > /etc/issue << 'EOF'

------------------------------
--- Welcome to eFa-$version ---
------------------------------
  http://www.efa-project.org
------------------------------

First time login: root/EfaPr0j3ct
EOF

cp $srcdir/eFa/eFa-SA-Update /usr/sbin/eFa-SA-Update
chmod 700 /usr/sbin/eFa-SA-Update
cp $srcdir/eFa/eFa-MS-Update /usr/sbin/eFa-MS-Update
chmod 700 /usr/sbin/eFa-MS-Update

# Write SSH banner
sed -i "/^#Banner / c\Banner /etc/banner"  /etc/ssh/sshd_config
cat > /etc/banner << 'EOF'
   Welcome to eFa (http://www.efa-project.org)

 Warning!

 THIS IS A PRIVATE COMPUTER SYSTEM. It is for authorized use only.
 Users (authorized or unauthorized) have no explicit or implicit
 expectation of privacy.

 Any or all uses of this system and all files on this system may
 be intercepted, monitored, recorded, copied, audited, inspected,
 and disclosed to authorized site and law enforcement personnel,
 as well as authorized officials of other agencies, both domestic
 and foreign.  By using this system, the user consents to such
 interception, monitoring, recording, copying, auditing, inspection,
 and disclosure at the discretion of authorized site personnel.

 Unauthorized or improper use of this system may result in
 administrative disciplinary action and civil and criminal penalties.
 By continuing to use this system you indicate your awareness of and
 consent to these terms and conditions of use.   LOG OFF IMMEDIATELY
 if you do not agree to the conditions stated in this warning.
EOF

# Compress logs from logrotate
sed -i "s/#compress/compress/g" /etc/logrotate.conf

  # Set the system as unconfigured
sed -i '1i\CONFIGURED:NO' /etc/eFa-Config