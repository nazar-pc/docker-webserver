FROM debian:jessie
LABEL maintainer "Nazar Mokrynskyi <nazar@mokrynskyi.com>"

CMD \

# Save all mounted volumes into tar file, name of which was specified by BACKUP_FILENAME environment variable

	tar -cf "/backup/$BACKUP_FILENAME.tar" $( \
		mount | \
		grep --invert-match --perl-regexp ' on /(dev|proc|sys|\s)' | \
		grep --invert-match --perl-regexp '/backup|/etc/(hostname|hosts|resolv.conf)' | \
		awk '{ print $3 }' \
	)
