#!/bin/sh

#SBATCH --job-name=filter
#SBATCH --time=50:00:00
#SBATCH --nodelist=meduza-2
#SBATCH --mem=100G

zgrep -v "^#" output.vcf.gz|wc -l > raw_snp_count.txt
vcftools --gzvcf output.vcf.gz --max-missing 0.60 --maf 0.01 --recode --recode-INFO-all --out filtration1

vcftools --vcf filtration1.recode.vcf --minQ 25 --minDP 3  --recode --recode-INFO-all --out filtration2.vcf
grep -v "^#" filtration2.vcf.recode.vcf|wc -l > filtered_snp_count.txt
bcftools view --max-alleles 2 --exclude-types indels filtration2.vcf.recode.vcf -o filtration3.vcf
grep -v "^#" filtration3.vcf|wc -l > filtered_biallelic_snp_count.txt
vcftools --vcf filtration3.vcf --plink --out output_data
vcftools --vcf filtration3.vcf --missing-indv
