#
# Regular cron jobs for the play.it package
#
0 4	* * *	root	[ -x /usr/bin/play.it_maintenance ] && /usr/bin/play.it_maintenance
