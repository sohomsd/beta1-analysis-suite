#!/bin/bash

mkdir -p slurm_output

scriptpath="$1"
shift
jobname="$1"
shift
trajtype="$1"
shift
numreplicas="$1"
shift
systems=("${@}")

for s in "${systems[@]}"; do
    cp scripts/job_template.sh tmp_job_submit.sh

    cat >> tmp_job_submit.sh <<-EOF

	source ~/.bashrc
	conda activate mdanalysis_sd
	python3 $scriptpath '$s' '$trajtype' '$numreplicas'
	EOF

	sbatch --job-name=$jobname\_$s tmp_job_submit.sh
done

rm tmp_job_submit.sh
exit
