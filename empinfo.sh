#!/bin/bash
# The above lines caues this scirpt to be run using the BASH
############################################################
#
#      Script to maintain a contact database.
#
############################################################

#
# Define the name of the file
#

fname=names.dat

#
#	set a name for all temp files used during this script
#

tmpfile=/tmp/`basename $0`.$$

#
#	pause()
#
# 	Ask the user to press ENTER and wait for then to do so
#

pause()
{
	echo -n "Hit <ENTER> to continue: "
	read junk
}

# 
#	yesno()
#
# 	A function do display a string passed in as $*), 
# 	If yes is answered, yesno() returns Yes or No answer
# 
yesno()
{
	while :
	do
		echo -n "$* (Y/N)?   "
		read yn junk

		case $yn in
			y|Y|yes|Yes|YES)
				return 0;;	# return TRUE
			n|N|no|No|NO)
				return 1;;	# return FALSE
			*)
				echo "Please answer Yes or No.";;
				#
				# and continue around the loop ...
				#
		esac
	done

}
#
#	usage
# 
#	Generic function to display a usage and exit the program
#	"basename" is used to transform "/home/sushilkumar/contacts"
#	into "contacts" (for example)
usage()
{
	script=$1
	shift 

	echo "Usage: `basename $script` $*" 1>&2
	exit 2

}
#
# 	do_create()
#	create records for our database
#

#
#	quit()
#
#	prompt the user to exit the program
# 
quit()
{
	#
	#	store the exit code away , coz calling another function
	# 	overwrite $1
	code=$1

	if yesno "Do you really wish to exit"
	then
		exit $code
	fi

}
#
# 	heading
#
heading()
{
echo "First Name    Surname          Address            City        State      Zip"
echo "============================================================================"
}


#
# print records
#

print_records()
{

	sort -t : +1 | while read aline
	do 

		echo $aline | awk -F : '{printf("%-14.14s%-16.16s%-20.20s%-15.15s%-6.6s%-5.5s\n", $1, $2, $3, $4, $5, $6)}'
	done
}


do_create()
{

	#
	# loop until the user is sick of entering record
	#
	while :
	do
		# Inner loop: loop until the user is satisfied
		# this ONE record
		#
		while :
		do
			# read in the contact details from the keyboard
			#
			clear
			echo "Please enter the following contact details"
			echo
			echo -n "Given name: "
			read name
			echo -n "   surname: "
			read surname
			echo -n "   Address: "
			read address
			echo -n "      City: "
			read city
			echo -n "     State: "
			read state
			echo -n "       Zip: "
			read zip
			#
			# Now confirm ...
			#
			clear

			echo "Your entered the following contact details"
			echo
			echo "Given name : $name"
			echo "    Surname: $surname"
			echo "    Address: $address"
			echo "       City: $city"
			echo "      State: $state"
			echo "        Zip: $zip"
			echo

			if yesno are these details correct
			then
				echo $name:$surname:$address:$city:$state:$zip >> $fname
				break
			fi
		done

		#
		# ASk the user if they wish to create another record
		#
		yesno Create another record || break
	done


}

#
#	do view()
#
#	Dispaly all records in the file, complete with headings
#	one page at a time
do_view()
{
	clear
			#
			#	Show what's currently in the file
			#
			
			( 
				heading
				#echo
				#echo Here are the current contacts in the database:
				#echo
				#echo "First Name    Surname          Address            City        State      Zip"
				#echo "============================================================================"
				#
				# display the line correctly formatted.
				# Use Awk for the formatting
				# "%-14.14s" means display a string in field with
				#
				#sort -t : +1 $fname | awk -F : '{printf("%-14.14s%-16.16s%-20.20s%-15.15s%-6.6s%-5.5s\n", $1, $2, $3, $4, $5, $6)}'
				cat $fname | print_records
			) | more


			# 
			# Display number of contact details in the file
			#

			echo
			echo "There are total `cat $fname | wc -l` contact(s) in the database"
			echo
			



}

#
# 	do search
#
do_search()
{
	echo -n "please enter a pattern to search for (ENTER for ALL): "
	read string

	echo

	if grep "$string" $fname > /dev/null
	then
		(
	
			heading

			grep "$string" $fname | print_records
	
	
		) | more
		return 0 	# we found some records
	else
		echo "Sorry, no records in file \"$fname\" contain \"$string\""
		return 1
	fi


}

do_delete()
{

	do_search && yesno "\nDelete All these records" || return

	if [ "$string" = "" ]
	then
		> $fname
		echo "All records deleted from file \"$fname\""
	else

		sed "/$string/d" $fname >> $tmpfile
		mv $tmpfile $fname
		
		echo "All records containig text \"$string\" deleted from file \"$fname\""
	fi

}


#
# 	START MAIN CODE HERE
#


trap "quit 3" 2 3
trap "exit 0" 1 15

#
#
#	check that there is exactly one argument.
#

#
#	check that there is exactly one argument
#

[ $# == 1 ] || usage $0 filename	# exits the program

#
# 	if we get here, they must have supplied a file name. store it away

fname=$1
#
#	If the file does not exist, create it

if [ ! -f $fname ] 
then
	echo $1 does not exist
	#
	# Ask if it should be created
	# 
	if yesno "Create it"
	then
		> $fname
		#
		#	check if that succeeded
		#	
		if [ ! -w $fname ]
		then
			echo $1 could not be created
			exit 2
		fi
		#
		#	otherwise we're OK
		#

	else
		#
		#	They didnt want to create it
		#
		exit 0
	fi
elif [ ! -w $fname ] # if exists - check if it can be written to
then
	echo could not open $1 for writing
	exit 2
fi

#
#	Loop forever - until they want to exit the program
#

while true
do
		#
		# Display the menu
		#
	clear
	echo -e "\n\t\tSHELL PROGRAMMING DATABASE"
	echo -e "\t\t\tMAIN MENU"
	echo -e "\nWhat do you wish to do?\n"
	echo -e "\t1.	Create records"
	echo -e "\t2.	View records"
	echo -e "\t3.	Search for records"
	echo -e "\t4.	Delete records that match a pattern"
	echo


	#
	#	Prompt for an answer
	#
	echo -n "Answer (or 'q' to quit)?  "
	read ans junk

	#
	# Empty answer (pressing ENTER) cause the manu to display
	# so .... back around loop
	# We only make it to the "continue" bit if the "test"
	# program ("[") return 0 (True)
	[ "$ans" = "" ] && continue

	#
	#
	# 	Decide what to do
	#
	case "$ans" in 
		1) 	do_create;;
		2)	do_view;;
		3)	do_search;;
		4)	do_delete;;

		q*|Q*)	quit 0;;
		*)
			echo "Please enter a number between 1 and 4"
			;;
	esac

	#
	# Puase to give the user a chance to see what's on the screen
	#
	pause
done
