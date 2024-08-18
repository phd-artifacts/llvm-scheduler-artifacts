# Getting Singularity images
```sh
singularity pull docker://ompcluster/hpcbase:ubuntu20.04-cuda11.2-mpich-ofed5
singularity pull docker://docker.io/ompcluster/runtime-dev:result_scheduler-main-ubuntu20.04-cuda11.2-mpich
singularity pull docker://docker.io/ompcluster/runtime-dev:result_improv-135-ubuntu20.04-cuda11.2-mpich
singularity pull docker://docker.io/ompcluster/runtime-dev:result_improv-136-ubuntu20.04-cuda11.2-mpich
singularity pull docker://registry.gitlab.com/ompcluster/containers/build-runtime-img/ubuntu20.04-cuda11.2-mpich:1405812206 
singularity pull docker://docker.io/ompcluster/runtime-dev
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

# or host_list=$(scontrol show hostname $(echo "$SLURM_JOB_NODELIST" | head -n 4 | tr '\n' ',' | sed 's/,$//'))

spinner  -c bench_settings.yaml -r T -e T --hosts r4n52,r4n53,r4n54,r4n55,r5n28,r5n29,r5n30,r5n31,r5n32,r5n33,r5n34,r5n35,r5n36,r5n37,r5n38,r5n39,r5n41,r5n42,r5n43,r5n44,r5n45,r5n46,r5n47,r5n48,r5n49,r5n50,r5n51,r5n52

```