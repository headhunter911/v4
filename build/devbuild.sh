#!/bin/bash
######################################################################
# eFa 4.0.1 Build script for local development builds
######################################################################
# Copyright (C) 2020  https://efa-project.org
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
#######################################################################

VERSION="4.0.2"

# Git path
GITPATH="/root/v4"

# check if user is root
if [ `whoami` == root ]; then
  echo "Good you are root."
else
  echo "ERROR: Please become root first."
  exit 1
fi

# check if we run CentOS 7
OSVERSION=`cat /etc/centos-release`
if [[ $OSVERSION =~ .*'release 7.'.* ]]; then
  echo "- Good you are running CentOS 7"
else
  echo "- ERROR: You are not running CentOS 7"
  echo "- ERROR: Unsupported system, stopping now"
  exit 1
fi

if [[ -f /etc/selinux/config && -n $(grep -i ^SELINUX=disabled$ /etc/selinux/config)  ]]; then
  echo "- ERROR: SELinux is disabled and this is not an lxc container"
  echo "- ERROR: Please enable SELinux and try again."
  exit 1
fi

if [[ ! -d /root/v4 ]]; then
  echo "- ERROR: git path is incorrect"
  echo "- ERROR: Please clone to /root/v4 or update GITPATH and try again."
  exit 1
fi

yum -y install epel-release
[ $? -ne 0 ] && exit 1

echo "- Adding IUS Repo"
yum -y install https://repo.ius.io/ius-release-el7.rpm
[ $? -ne 0 ] && exit 1
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-IUS-7
[ $? -ne 0 ] && exit 1

yum -y update
[ $? -ne 0 ] && exit 1

yum -y remove mariadb-libs
[ $? -ne 0 ] && exit 1

yum -y install rpm-build rpmdevtools gcc-c++ gcc perl-Net-DNS perl-NetAddr-IP openssl-devel perl-Test-Pod \
  perl-HTML-Parser perl-Archive-Tar perl-devel perl-libwww-perl perl-DB_File perl-Mail-SPF perl-Encode-Detect \
  perl-IO-Socket-INET6 perl-Mail-DKIM perl-Net-DNS-Resolver-Programmable perl-Parse-RecDescent perl-Inline \
  perl-Test-Manifest perl-YAML perl-ExtUtils-CBuilder perl-Module-Build perl-IO-String perl-Geo-IP \
  perl-Net-CIDR-Lite perl-Sys-Hostname-Long perl-Net-IP perl-Net-Patricia perl-Data-Dump perl-generators \
  libicu-devel openldap-devel mysql-devel postgresql-devel sqlite-devel tinycdb-devel perl-Date-Calc \
  perl-Sys-Syslog clamav perl-Geography-Countries php72u mariadb101u-server perl-Digest-SHA1 php72u-gd \
  php72u-ldap php72u-mbstring php72u-mysqlnd php72u-xml perl-Archive-Zip perl-Env perl-Filesys-Df \
  perl-IO-stringy perl-Net-CIDR perl-OLE-Storage_Lite perl-Sys-SigAction perl-MIME-tools wget \
  php72u-json perl-Test-Simple php72u-cli m4 perl-Math-Int64 perl-Path-Class perl-Test-Fatal \
  perl-Test-Number-Delta perl-namespace-autoclean perl-Role-Tiny perl-Data-Dumper-Concise \
  perl-DateTime perl-Test-Warnings perl-autodie perl-Test-Requires perl-Test-Tester perl-Clone-PP \
  perl-File-HomeDir perl-Sort-Naturally perl-JSON-MaybeXS perl-LWP-Protocol-https perl-Test-LeakTrace \
  perl-Throwable libmaxminddb-devel
[ $? -ne 0 ] && exit 1

mkdir -p $GITPATH/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
[ $? -ne 0 ] && exit 1
echo "%_topdir $GITPATH/rpmbuild" > ~/.rpmmacros
[ $? -ne 0 ] && exit 1
cd $GITPATH/rpmbuild/SPECS
[ $? -ne 0 ] && exit 1
rpmbuild -ba postfix.spec
[ $? -ne 0 ] && exit 1
yum -y remove postfix postfix32u
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/postfix_eFa-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba clamav-unofficial-sigs.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/clamav-unofficial-sigs-*.rpm
[ $? -ne 0 ] && exit 1
echo "n" | rpmbuild -ba perl-libnet.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-libnet-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-IP-Country.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-IP-Country-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Text-Balanced.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Text-Balanced-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Mail-SPF-Query.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Mail-SPF-Query-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba unrar-5.8.3.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/unrar-*.rpm
[ $? -ne 0 ] && exit 1
# BEGIN: New modules for spamassassin 3.4.4 development builds
rpmbuild -ba perl-IP-Country-DB_File.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-IP-Country-DB_File-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Sub-Quote.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Sub-Quote-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Module-Runtime.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Module-Runtime-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Role-Tiny.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Role-Tiny-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Moo.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Moo-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Scalar-List-Utils.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Scalar-List-Utils-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-List-SomeUtils.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-List-SomeUtils-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-List-SomeUtils-XS.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-List-SomeUtils-XS-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-List-UtilsBy.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-List-UtilsBy-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-List-AllUtils.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-List-AllUtils-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-strictures.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-strictures-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-MooX-StrictConstructor.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-MooX-StrictConstructor-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-MaxMind-DB-Metadata.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-MaxMind-DB-Metadata-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Test-Bits.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Test-Bits-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Data-IEEE754.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Data-IEEE754-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Data-Printer.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Data-Printer-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Data-Validate-IP.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Data-Validate-IP-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-MaxMind-DB-Reader.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-MaxMind-DB-Reader-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-GeoIP2-Country-Reader.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-GeoIP2-Country-Reader-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Math-Int128.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Math-Int128-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Net-Works-Network.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Net-Works-Network-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-MaxMind-DB-Reader-XS.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-MaxMind-DB-Reader-XS-*.rpm
[ $? -ne 0 ] && exit 1
# END: New modules for spamassassin 3.4.4 development builds
rpmbuild -ba Spamassassin.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/spamassassin-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Encoding-FixLatin.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Encoding-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba perl-Sendmail-PMilter.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/perl-Sendmail-PMilter-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba MailWatch.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/MailWatch-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba sqlgreywebinterface.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/sqlgreywebinterface-*.rpm
[ $? -ne 0 ] && exit 1
cd $GITPATH/rpmbuild/SOURCES
[ $? -ne 0 ] && exit 1
rm -f eFa-$VERSION.tar.gz
[ $? -ne 0 ] && exit 1
tar czvf eFa-$VERSION.tar.gz eFa-$VERSION/
[ $? -ne 0 ] && exit 1
rm -f eFa-base-4.0.0.tar.gz
[ $? -ne 0 ] && exit 1
tar czvf eFa-base-4.0.0.tar.gz eFa-base-4.0.0/
[ $? -ne 0 ] && exit 1
rpmbuild -ba mailscanner.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/MailScanner-*.rhel.noarch.rpm
[ $? -ne 0 ] && exit 1
cd $GITPATH/rpmbuild/SPECS
[ $? -ne 0 ] && exit 1
rpmbuild -ba dcc.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/dcc-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba eFa4-base.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/eFa-base-*.rpm
[ $? -ne 0 ] && exit 1
rpmbuild -ba eFa4.spec
[ $? -ne 0 ] && exit 1
yum -y install $GITPATH/rpmbuild/RPMS/x86_64/eFa-4*.rpm
[ $? -ne 0 ] && exit 1
