#!/bin/bash

set -e

# Array of branch names to be processed
branches=("main" "multiqueue" "tasksharing" "libomp")

# Folder with the .sif files
sif_folder="/home/users/r176848/remy/sif"

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
    path="/home/users/r176848/remy/llvm/$branch"
    install_path="/home/users/r176848/remy/llvm/installs/$branch/Release"

    # make install directory
    mkdir -p $install_path
    cd $install_path

    export CC=clang
    export CXX=clang++

    # Determine the correct SIF path for the current branch
    sif_path=$(map_branch_to_sif "$branch")

    # Navigate to the llvm directory and clone task-bench if it doesn't exist
    mkdir -p $path
    cd $path
    if [ ! -d "task-bench" ]; then
      git clone https://gitlab.com/ompcluster/task-bench.git $path
    fi

    # Navigate to the task-bench directory and clean previous builds
    cd task-bench/$branch
    if [ -d "deps" ]; then
      rm -r "deps"
    fi

    # Use the SIF image to build the dependencies and the project
    singularity exec --nv $sif_path bash -c "$CC  --version"
    singularity exec --nv $sif_path bash -c "$CXX  --version"
    singularity exec --nv $sif_path bash -c "DEFAULT_FEATURES=0 USE_OMPCLUSTER=1 ./get_deps.sh"
    singularity exec --nv $sif_path bash -c "DEFAULT_FEATURES=0 USE_OMPCLUSTER=1 ./build_all.sh"

    if [ $? -ne 0 ]; then
        echo "Failed to compile Task-Bench for branch: $branch"
        exit 1
    fi
done

echo "Compilation complete for all branches."
