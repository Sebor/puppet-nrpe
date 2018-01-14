#!/bin/bash

STATE_OK=0
STATE_WARN=1
STATE_CRIT=2
STATE_UNKNOWN=3

EXPIRED=0
EXPIRED_NAMES=""
EXPIRE_SOON=0
EXPIRE_SOON_NAMES=""
WARNING_INTERVAL=4 #Days

# default key file locations
_l="/etc/login.defs"
_p="/etc/passwd"

# get mini UID limit
l=$(grep "^UID_MIN" $_l)

# get max UID limit
l1=$(grep "^UID_MAX" $_l)

# find the normal users use awk to print if UID >= $MIN and UID <= $MAX and
# shell is not /sbin/nologin 
awk -F':' -v "min=${l##UID_MIN}" -v "max=${l1##UID_MAX}" '{ if ( $3 >= min && $3 <= max  && $7 != "/sbin/nologin" ) print $1 }' "$_p" > /tmp/normal_users

while read user_name
do

  # check to see if the user's password does not expire
  if [ `chage -l $user_name | grep "Password expires" | grep -c "never"` -eq 1 ] ; then
#    echo "Password never expires for $user_name"
    continue
  fi

  # check to see if the user's password must be changed
  if [ `chage -l $user_name | grep "Password expires" | grep -c "password must be changed"` -eq 1 ] ; then
#    echo "Password must be changed for $user_name"
     true
  fi

  ## get the user password configuration

  # retrieve the day of the last password change (lastchanged) in days since
  # Jan 1, 1970 that password was last changed
  last_password_change=`grep $user_name /etc/shadow | cut -d: -f3`
#  echo "$user_name last_password_change $last_password_change"

  # retrieve the number of days that a password is valid which that user is
  # forced to change his/her password
  validity_period=`grep $user_name /etc/shadow | cut -d: -f5`
#  echo "$user_name password valid for $validity_period days"

  # retrieve the number of days before password is to expire that user is
  # warned that his/her password must be changed
  warning_period=`grep $user_name /etc/shadow | cut -d: -f6`
#  echo "$user_name password expiry warning period $warning_period days"

  ## calculate the relevant intervals

  # get the current day in days since Jan 1, 1970
  current_day=`perl -e 'print int(time/(60*60*24))'`
#  echo "$user_name current day $current_day"

  # compute the age of the user's password
  password_age=`echo $current_day - $last_password_change + 1 | bc`
#  echo "$user_name password age $password_age"

  # calculate the number of days until the password expires
  days_until_expired=`echo $validity_period - $password_age | bc`
#  echo "$user_name has $days_until_expired days until the password expires"
     
  # alert if the password has expired
  if [ $days_until_expired -lt 1 ] ; then
#    echo "ALERT: User $user_name has had the password expire $days_until_expired days ago. "
    EXPIRED=$(($EXPIRED+1))
    EXPIRED_NAMES="$EXPIRED_NAMES $user_name"
#    echo "Your ($user_name) password expired and must be changed" | mail -r "$(hostname)" -s "EXPIRED password" $user_name >/dev/null 2>&1
    if [ $(date +%H%M) -gt 1000 ] && [ $(date +%H%M) -lt 1120 ]; then
      echo "Your ($user_name) password expired and must be changed" | mail -r "$(hostname)" -s "EXPIRED password" $user_name >/dev/null 2>&1
    fi
    if [ $(date +%H%M) -gt 1750 ] && [ $(date +%H%M) -lt 1910 ]; then
      echo "Your ($user_name) password expired and must be changed" | mail -r "$(hostname)" -s "EXPIRED password" $user_name >/dev/null 2>&1
    fi
    continue
  fi

  # warn if the number of days to go in the validity period is less than the
  # warning period
  if [ $days_until_expired -lt $WARNING_INTERVAL ] ; then
#    echo "WARNING: User $user_name has $days_until_expired days to change their password. "
    EXPIRE_SOON=$(($EXPIRE_SOON+1))
    EXPIRE_SOON_NAMES="$EXPIRE_SOON_NAMES $user_name"
#    echo "Your ($user_name) password will expire in $days_until_expired days" | mail -r "$(hostname)" -s "EXPIRE SOON password" $user_name >/dev/null 2>&1
    if [ $(date +%H%M) -gt 1000 ] && [ $(date +%H%M) -lt 1120 ]; then
      echo "Your ($user_name) password will expire in $days_until_expired days" | mail -r "$(hostname)" -s "EXPIRE SOON password" $user_name >/dev/null 2>&1 
    fi
    if [ $(date +%H%M) -gt 1750 ] && [ $(date +%H%M) -lt 1910 ]; then
      echo "Your ($user_name) password will expire in $days_until_expired days" | mail -r "$(hostname)" -s "EXPIRE SOON password" $user_name >/dev/null 2>&1
    fi
    continue
  fi

done < /tmp/normal_users

if [ $EXPIRED -gt 0 ]
then
	#echo "CRITICAL - expired passwords count = $EXPIRED ($EXPIRED_NAMES) ; expiring soon = $EXPIRE_SOON ($EXPIRE_SOON_NAMES)" | mailx -r "root" -s "Expired passwords on server `hostname`" unix-admins@example.com >/dev/null 2>&1
	echo "CRITICAL - expired passwords count = $EXPIRED ($EXPIRED_NAMES) expiring soon = $EXPIRE_SOON ($EXPIRE_SOON_NAMES) | 'expired'=$EXPIRED 'expiring'=$EXPIRE_SOON"
#	exit $STATE_CRIT
	exit $STATE_WARN
elif [ $EXPIRE_SOON -gt 0 ]
then
	#echo "WARNING - soon expiring passwords count = $EXPIRE_SOON ($EXPIRE_SOON_NAMES)" | mailx -r "root" -s "Expired passwords on server `hostname`" unix-admins@example.com >/dev/null 2>&1
	echo "WARNING - soon expiring passwords count = $EXPIRE_SOON ($EXPIRE_SOON_NAMES) | 'expired'=$EXPIRED 'expiring'=$EXPIRE_SOON"
	exit $STATE_WARN
fi

echo "OK - no expiring/expired passwords | 'expired'=$EXPIRED 'expiring'=$EXPIRE_SOON"
exit $STATE_OK

