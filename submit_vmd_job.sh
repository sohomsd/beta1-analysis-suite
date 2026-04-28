#!/bin/bash

mkdir -p slurm_output

scriptpath="$1"
shift
jobname="$1"
shift
systems=("${@}")

for s in "${systems[@]}"; do
    cp src/job_template.sh tmp_job_submit.sh

    cat >> tmp_job_submit.sh <<-EOF

	source ~/.bashrc
	vmd='/software/apps/vmd/vmd-1.9.4a51_CUDA/install_bin/vmd'
	\$vmd -dispdev text -args $s < $scriptpath 
	EOF

	sbatch --job-name=$jobname\_$s tmp_job_submit.sh
done

rm tmp_job_submit.sh
exit
