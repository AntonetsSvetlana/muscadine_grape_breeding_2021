#!/bin/sh
#SBATCH --job-name=fastqc_analysis
#SBATCH --time=50:00:00

fastqc -o /nfs/home/eraines/data/subset_lane1.fastq
