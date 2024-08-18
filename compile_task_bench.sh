#!/bin/bash

set -e

# Array of branch names to be processed
branches=("main" "multiqueue" "tasksharing" "libomp")

# Folder with the .sif files
sif_folder="."

# Function to map branches to their respective .sif paths
map_branch_to_sif() {
  local branch="$1"
  case "$branch" in
  "main")
    echo "$sif_folder/runtime-dev_result_scheduler-main-ubuntu20.04-cuda11.2-mpich.sif"
    ;;
  "libomp")
    echo "$sif_folder/runtime-dev_result_improv-135-ubuntu20.04-cuda11.2-mpich.sif"
    ;;
  "baseline")
    echo "$sif_folder/runtime-dev_latest.sif"
    ;;
  "tasksharing")
    echo "$sif_folder/runtime-dev_result_improv-136-ubuntu20.04-cuda11.2-mpich.sif"
    ;;
  "multiqueue")
    echo "$sif_folder/ubuntu20.04-cuda11.2-mpich_1405812206.sif"
    ;;
  *)
    echo "No SIF image path found for branch '$branch'"
    ;;
  esac
}

# Loop through each branch and execute the build process
for branch in "${branches[@]}"; do
    echo "Compiling Task-Bench for branch: $branch"
    # Determine the correct SIF path for the current branch
    sif_path=$(map_branch_to_sif "$branch")
    
    # Remove the existing branch directory and copy the task-bench directory
    # if exists
    if [ -d $branch ]; then
      rm -r $branch
    fi

    cp -r task-bench $branch

    cd $branch

    # Navigate to the task-bench directory and clean previous builds
    if [ -d "deps" ]; then
      rm -r "deps"
    fi


    # Use the SIF image to build the dependencies and the project
    singularity exec --nv ../$sif_path bash -c "CC=clang CXX=clang++ DEFAULT_FEATURES=0 USE_OMPCLUSTER=1 ./get_deps.sh"
    singularity exec --nv ../$sif_path bash -c "CC=clang CXX=clang++ DEFAULT_FEATURES=0 USE_OMPCLUSTER=1 ./build_all.sh"
    cd ..

done

echo "Compilation complete for all branches."
