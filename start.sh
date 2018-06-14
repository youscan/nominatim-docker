#!/bin/bash
tail -f /var/log/apache2/* &
/usr/sbin/apache2ctl -D FOREGROUND
