#!/bin/bash

cd $2
args=("$@")

"${args[@]:2}" 
kill $1