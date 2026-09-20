dir=($pwd)

if [ $# -eq 0 ]; then 
  echo -e "usage: no arg is provided.\n"
  exit 1
elif [ $# -gt 1 ]; then
  echo -e "usage: more than one arguments are provided.\n"
  exit 1
fi
