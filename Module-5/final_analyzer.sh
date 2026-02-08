#!/bin/bash
 
error_log="errors.log"
 
log_error() {
  echo "$1" | tee -a "$error_log" >&2
}
 
show_help() {
cat << EOF
Usage: $0 [-d directory] [-f file] -k keyword [--help]
 
Options:
  -d directory   Search recursively in a directory
  -f file        Search directly in a file
  -k keyword     Keyword to search
  --help         Display this help menu
 
Examples:
  $0 -d logs -k error
  $0 -f script.sh -k TODO
  $0 --help
EOF
}
 
search_dir() {
  local dir="$1"
  local key="$2"
 
  for item in "$dir"/*; do
    if [ -d "$item" ]; then
      search_dir "$item" "$key"
    elif [ -f "$item" ]; then
      grep -H "$key" "$item" 2>>"$error_log"
    fi
  done
}
 
if [ "$#" -eq 0 ]; then
  log_error "No arguments provided"
  show_help
  exit 1
fi
 
while [[ "$1" == --* ]]; do
  case "$1" in
    --help)
      show_help
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      exit 1
      ;;
  esac
done
 
while getopts ":d:f:k:" opt; do
  case $opt in
    d) directory="$OPTARG" ;;
    f) file="$OPTARG" ;;
    k) keyword="$OPTARG" ;;
    *)
      log_error "Invalid option"
      exit 1
      ;;
  esac
done
 
if [ -z "$keyword" ]; then
  log_error "Keyword cannot be empty"
  exit 1
fi
 
if ! [[ "$keyword" =~ ^[a-zA-Z0-9_]+$ ]]; then
  log_error "Invalid keyword format"
  exit 1
fi
 
if [ -n "$directory" ]; then
  if [ ! -d "$directory" ]; then
    log_error "Directory does not exist"
    exit 1
  fi
  search_dir "$directory" "$keyword"
elif [ -n "$file" ]; then
  if [ ! -f "$file" ]; then
    log_error "File does not exist"
    exit 1
  fi
  grep -H "$keyword" "$file" 2>>"$error_log"
else
  log_error "Either directory (-d) or file (-f) must be provided"
  exit 1
fi
 
status=$?
echo "Script: $0"
echo "Arguments count: $#"
echo "Exit status: $status"
 