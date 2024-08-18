# Reproducibility artifacts

This repository contains scripts for both running and plotting all the data measured and ported in the paper. The instructions are structured as follows: we use Singularity images the the consolidated running enviroment for each implementation.

From that, we rely on the helper application Spinner (added here as a submodule) to manage repeated executions and output capture. To reproduce, in a enviroment with 28 nodes, follow the steps below to pull all container images, then use the helper script to compile task bench using each of the containers.

Finaly, use Spinner with the bench_settings.yaml paramter swap file. Finally, use the plots.ipynb to plot the results.

# Getting Singularity images
```sh
singularity pull docker://ompcluster/hpcbase:ubuntu20.04-cuda11.2-mpich-ofed5
singularity pull docker://docker.io/ompcluster/runtime-dev:result_scheduler-main-ubuntu20.04-cuda11.2-mpich
singularity pull docker://docker.io/ompcluster/runtime-dev:result_improv-135-ubuntu20.04-cuda11.2-mpich
singularity pull docker://docker.io/ompcluster/runtime-dev:result_improv-136-ubuntu20.04-cuda11.2-mpich
singularity pull docker://registry.gitlab.com/ompcluster/containers/build-runtime-img/ubuntu20.04-cuda11.2-mpich:1405812206 
singularity pull docker://docker.io/ompcluster/runtime-dev
```

# Compile Task-Banch
Use the helper script
```sh
./compile_task_bench.sh
```

# Prepare Spinner
```sh
python3 -m ensurepip
python3 -m pip3 install virtualenv
python3 -m virtualenv .venv
source .venv/bin/activate
python3 -m pip install pip --upgrade
python -m pip install .
```

# Running the experiment
```sh
source spinner/.venv/bin/activate      

module load mpich/4.0.2-cuda-12.4.0-ucx
module load singularity/3.7.1

# or host_list=$(scontrol show hostname $(echo "$SLURM_JOB_NODELIST" | tr '\n' ',' | sed 's/,$//'))

spinner -c bench_settings.yaml -r T -e T --hosts host1,host2,host3,

```