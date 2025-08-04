#!/bin/bash
set -e

handle_file () {
	local filename=$1
	local target=$2
	if [ -e "$target" ]; then
		rm $target
	fi
	ln $filename $target
}

handle_dir () {
	local folder=$1
	local mafiaequiv=$2
	local dironly=$3
	if [ ! -d "$mafiaequiv" ]; then
		mkdir $mafiaequiv
	fi
	pushd $folder
	for filename in *; do
		if [ "$filename" == "dependencies.txt" ] || [ "$filename" == "README.md" ]; then
			continue
		fi
		if [ -d "$filename" ]; then
			handle_dir "$filename" "$mafiaequiv/$filename"
		else
			if [ "$dironly" == "" ]; then
				handle_file "$filename" "$mafiaequiv/$filename"
			fi
		fi
	done
	popd
}

echo "relinking"
handle_dir "src" ~/.kolmafia "dironly"
echo "done"
