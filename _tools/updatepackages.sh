#!/bin/bash

set -e

if [ ! -e "_tools/updatepackages.sh" ]; then
  echo "Please run this script from the root directory."; exit 1
fi

if [ "$1" = "help" ]; then
	echo "No commands required to execute this tool,"
	echo "just run 'site updatepackages'."
	exit
fi

rm -f _data/packages.json _data/package_updates.json

curl \
	-L https://github.com/redtide/archdroid-org.github.io/releases/download/packages_data/packages.json \
	> _data/packages.json

curl \
	-L https://github.com/redtide/archdroid-org.github.io/releases/download/packages_data/package_updates.json \
	> _data/package_updates.json

changes=1
new=0
removed=0

echo "Checking for packages that have been removed..."
while read -r package
do
	if [ "$package" = "" ]; then
		continue
	fi
	if ! grep "\"name\": \"$package\"" _data/packages.json > /dev/null ; then
		echo "  Removing $package."
		((removed=removed+1))
		changes=0
	fi
done < <(find packages -maxdepth 1 -type d | tail -n +2 | cut -d"/" -f2)

name="\"name\": "

echo "Checking for new packages..."
while IFS="" read -r line || [ -n "${line}" ]
do
	if [[ ${line} == *${name}* ]]; then
		tempstr=${line/${name}/}
		pkgname=$(echo ${tempstr} | sed -e 's/[\",]//g')
		dir="packages/${pkgname}"
		index="${dir}/index.md"
		[[ -d ${dir} ]] || mkdir -p ${dir}
		if [[ ! -f "${index}" ]]; then
			echo "  Adding $pkgname."
			((new=new+1))
			cat <<EOF >${index}
---
title:  "${pkgname}"
layout: "archdroid/package"
---
EOF
			changes=0
		fi
	fi
done < _data/packages.json

update_file=_data/package_updates.json

if which jq > /dev/null 2>&1 ; then
	if [ ! -f $update_file ]; then
		echo "ERROR: $update_file does not exists."
		exit 1
	fi

	echo "Generating $update_file..."
	current_md5sum=$(md5sum $update_file | cut -d" " -f1)

	jq 'sort_by(.builddate) | reverse | [limit(10;.[])]' \
		_data/packages.json > $update_file

	new_md5sum=$(md5sum $update_file | cut -d" " -f1)

	if [ "$current_md5sum" != "$new_md5sum" ]; then
		changes=0
	fi
fi

echo "New packages     : $new"
echo "Removed packages : $removed"

# return false if no changes occurred.
#exit $changes
