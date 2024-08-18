set -e

branch=$1
path="/home/users/r176848/remy/llvm/$branch"
install_path="/home/users/r176848/remy/llvm/installs/$branch/Release"

# load required modules
module purge
module load cmake/3.27.9
module load mpich/4.0.2-cuda-12.4.0-ucx
module load singularity/3.7.1

# make install directory
mkdir -p $install_path
cd $install_path

export CC=clang
export CXX=clang++

map_branch_to_sif() {
  local branch="$1"
  case "$branch" in
  "main")
    echo "/home/users/r176848/remy/sif/runtime-dev_result_scheduler-main-ubuntu20.04-cuda11.2-mpich.sif"
    ;;
  "libomp")
    echo "/home/users/r176848/remy/sif/runtime-dev_result_improv-135-ubuntu20.04-cuda11.2-mpich.sif"
    ;;
  "baseline")
    echo "/home/users/r176848/remy/sif/runtime-dev_latest.sif"
    ;;
  "tasksharing")
    echo "/home/users/r176848/remy/sif/runtime-dev_result_improv-136-ubuntu20.04-cuda11.2-mpich.sif"
    ;;
  "multiqueue")
    echo "/home/users/r176848/remy/sif/ubuntu20.04-cuda11.2-mpich_1405812206.sif"
    ;;
  *)
    echo "No SIF image path found for branch '$branch'"
    ;;
  esac
}

sif_path=$(map_branch_to_sif "$branch")

# build task-bench
cd /home/users/r176848/remy/task-bench/$branch
# remove the "deps" folder if it exists
if [ -d "deps" ]; then
  rm deps -r
fi

# User the SIF image to build the dependencies
singularity exec --nv $sif_path bash -c "$CC  --version"
singularity exec --nv $sif_path bash -c "$CXX  --version"
singularity exec --nv $sif_path bash -c "DEFAULT_FEATURES=0 USE_OMPCLUSTER=1 ./get_deps.sh"
singularity exec --nv $sif_path bash -c "DEFAULT_FEATURES=0 USE_OMPCLUSTER=1 ./build_all.sh"
