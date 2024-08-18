#!/bin/bash

# Declare an array of branch names
branches=("main" "multiqueue" "tasksharing" "libomp")

# Loop through each branch and execute the scripts
for branch in "${branches[@]}"
    echo "Compiling TB for branch: $branch"
    ./compile_tb.sh $branch
    if [ $? -ne 0 ]; then
        echo "Failed to compile TB for branch: $branch"
        exit 1
    fi
done

echo "Compilation complete for all branches."