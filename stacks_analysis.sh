#!/bin/sh
#SBATCH --job-name=stacks_analysis
#SBATCH --time=50:00:00

stacks -o /nfs/home/eraines/data/demultiplexing_data -b /nfs/home/eraines/data/column296.txt -p /nfs/home/eraines/data/raw_data/
