#!/bin/bash



if [ $# -eq 0 ]; then
  echo "usage: no arg is provided."
  exit 1
fi

if [ $# -gt 1 ]; then
  echo "usage: more than one arguments are provided."
  exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
  echo "usage: input is not a file or it does not exist."
  exit 1
fi

if [[ "$FILE" != *.vsc ]]; then
  echo "usage: input does not have the extension .vsc."
  exit 1
fi

if [ ! -s "$FILE" ]; then
  echo "usage: the file is empty - no .bin file is produced."
  exit 1
fi

# --- read the whole file into an array (portable: works even on old bash) ---
lines=()
while IFS= read -r line || [ -n "$line" ]; do
  line="${line%$'\r'}"
  lines+=("$line") 
done < "$FILE"

n_values=${lines[0]}
output_bytes=()

# --- static values -> memory addresses 0..n_values-1, 1 byte each ---
i=1
while [ "$i" -le "$n_values" ]; do
  val=${lines[$i]}
  output_bytes+=("$(printf "%02x" "$val")")
  i=$((i + 1))
done

# --- opcode table (case statement instead of assoc array = works on bash 3.2 too) ---
opcode_of() {
  case "$1" in
    LOAD)  echo 1 ;;
    STORE) echo 2 ;;
    ADD)   echo 3 ;;
    SUB)   echo 4 ;;
    QUIT)  echo 8 ;;
    PRINT) echo 9 ;;
    *)     echo "" ;;
  esac
}

has_add_sub=0
has_quit=0
start=$((n_values + 1))
total=${#lines[@]}

i=$start
while [ "$i" -lt "$total" ]; do
  line="${lines[$i]}"
  if [ -n "$line" ]; then
    IFS=',' read -r opname reg addr <<< "$line"
    opname=$(echo "$opname" | tr -d '[:space:]')
    reg=$(echo "$reg" | tr -d '[:space:]')
    addr=$(echo "$addr" | tr -d '[:space:]')

    opcode=$(opcode_of "$opname")

    # instruction = 16 bits: opcode(6) | register(2) | address(8)
    # byte1 = opcode shifted left 2, OR'd with the register bits
    byte1=$(( (opcode << 2) | reg ))
    byte2=$addr

    output_bytes+=("$(printf "%02x" "$byte1")")
    output_bytes+=("$(printf "%02x" "$byte2")")

    [ "$opname" = "ADD" ] || [ "$opname" = "SUB" ] && has_add_sub=1
    [ "$opname" = "QUIT" ] && has_quit=1
  fi
  i=$((i + 1))
done

if [ "$has_add_sub" -eq 1 ]; then
  echo "It is an ADD/SUB program"
elif [ "$has_quit" -eq 1 ]; then
  echo "It is a QUIT program"
fi

echo "The content of the .bin file is"
for b in "${output_bytes[@]}"; do
  echo "$b"
done

# --- also actually produce the .bin file (the assignment asks for a real binary output) ---
BOUT="${FILE%.vsc}.bin"
: > "$BOUT"
for b in "${output_bytes[@]}"; do
  printf "\\x$b" >> "$BOUT"
done

exit 0
