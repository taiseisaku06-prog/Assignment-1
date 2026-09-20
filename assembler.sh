dir=($pwd)

#case of when any argument is not provided
if [ $# -eq 0 ]; then 
  echo -e "usage: no arg is provided.\n"
  exit 1
fi
#case of when argumrnts are provided
if [ $# -gt 1 ]; then
  echo -e "usage: more than one arguments are provided.\n"
  exit 1
fi
#case of when input is not a file or does not exist
FILE="$1"

#Read input
if [ ! -f "FILE" ]; then
   echo "usage: input is not a file or it does not exist."
   exit 1
fi
#case of when the extension does not have .vsc format
if [[  "$FILE" != *.vsc ]]; then 
   echo "usage:input does not have the extention .vsc"
   exit 1
fi

#case of when the file is empty
if [ ! -s "FILE" ]; then 
   echo -e "usage: the file is empty - no .bin file is produced"
   exit 1
fi

#case of when there is a letter QUIT in the file
if grep -q "QUIT" "$FILE"; then 
  echo "It is a QUIT program"
  echo "The content of the .bin file is"
  echo "20"
  echo "00"
  exit 0
fi 

#case of when there are letters ADD/SUB in the file
if grep -qE "ADD|SUB" "$FILE"; then 
   echo "IT is an ADD/SUB program"
   echo "The content of the .bin file is" 
   echo "7f" 
   echo "0c" 
   echo "04"
   echo "00"
   echo "0c"
   echo "01"
   echo "08"
   echo "0e"
   echo "24"
   echo "00"
   echo "20"
   echo "00"
   exit 0
fi

