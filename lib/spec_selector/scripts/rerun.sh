#!/bin/bash

cd $2
args=("$@")
len=${args[@]: -1}
let start=-$len-1

filter() {
  descriptions=()
  for arg in "${args[@]: $start: $len}"
    do description=$(echo $arg | sed 's/^\[//;s/\]$//;s/,$//')
    for (( i=0; i<${#description}; i++ )); do
      if [ "${description:$i:1}" = "'" ]; then
        description="\"$description\""
        escaped=true
        break
      fi
    done

  if ! [ $escaped ]; then
    description="'$description"
    description="$description'"
  fi
  
  descriptions+=" -e "
  descriptions+=$description
  done
}

let length=$#+$start-2

if [ $len -eq 0 ]
then
  eval "${args[@]:2:$length}"
else
  filter
  eval "${args[@]:2:$length} ${descriptions[@]}"
fi

kill $1