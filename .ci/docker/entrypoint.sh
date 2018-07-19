#!/bin/bash

/usr/sbin/sendmail -bd -q1h

exec "$@"