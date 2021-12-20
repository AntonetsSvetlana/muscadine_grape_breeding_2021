#!/bin/sh

#SBATCH --job-name=index
#SBATCH --time=50:00:00
#SBATCH --nodelist=meduza-2
#SBATCH --mem=100G


###FastQC, MultiQC

for file in *.fq.gz;
do
	fastqc -o /mnt/tank/scratch/eraines/real_data_for_project/fastqc_before/ $file
done

multiqc /mnt/tank/scratch/eraines/real_data_for_project/fastqc_before/

###Trimming

for file in *.fq.gz;
do
	trimmomatic SE $file /mnt/tank/scratch/eraines/real_data_for_project/trimmed/"${file%%.*}".trimmed.fq.gz ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 SLIDINGWINDOW:4:15
done



###FastQC, MultiQC

for file in *.trimmed.fq.gz;
do
	fastqc -o /mnt/tank/scratch/eraines/real_data_for_project/fastqc_after_trimming/ $file
done

multiqc /mnt/tank/scratch/eraines/real_data_for_project/fastqc_after_trimming/

"""
###Filtering reference file to include only hap1

grep -w 'hap1' VITMroTrayshed_v2.0.fasta > 
seqtk subseq /mnt/tank/scratch/santonec/real_data_for_project/ref_genome/VITMroTrayshed_v2.0.fasta hap1.lst > /mnt/tank/scratch/santonec/real_data_for_project/ref_genome/VITMroTrayshed_v2.0_hap1.fasta
"""


###GATK SNP calling.

"""
###Index Regerence

bwa index /mnt/tank/scratch/santonec/real_data_for_project/ref_genome/VITMroTrayshed_v2.0_hap1.fasta
samtools faidx /mnt/tank/scratch/santonec/real_data_for_project/ref_genome/VITMroTrayshed_v2.0_hap1.fasta

gatk CreateSequenceDictionary -R /mnt/tank/scratch/santonec/real_data_for_project/ref_genome/VITMroTrayshed_v2.0_hap1.fasta
"""

### Alignment
for file in *.trimmed.fq.gz;
do
	bwa mem -M -t 2 -R "@RG\tID:SRR622461.7\tSM:$file\tLB:ERR194147\tPL:ILLUMINA" /mnt/tank/scratch/eraines/real_data_for_project/ref_genome/VITMroTrayshed_v2.0_hap1.fasta /mnt/tank/scratch/eraines/real_data_for_project/trimmed/$file | samtools view -b -h -o /mnt/tank/scratch/eraines/real_data_for_project/aligned/"${file%%.*}".trimmed.bam
done

###QC after alignment
for file in trimmed/*.trimmed.bam;
do
	fastqc -o /mnt/tank/scratch/santonec/real_data_for_project/lib1/fastqc_trimmed/ $file
done

multiqc /mnt/tank/scratch/santonec/real_data_for_project/lib1/fastqc_trimmed/

### Sort sam
for file in *.trimmed.bam;
do
	picard -Xmx7g SortSam I=$file O="${file%%.*}".sort.trimmed.bam VALIDATION_STRINGENCY=LENIENT SORT_ORDER=coordinate CREATE_INDEX=True
done

###Index file
for file in *.sort.trimmed.bam;
do
	samtools index /mnt/tank/scratch/eraines/real_data_for_project/aligned/$file
done
###Variant calling
for file in *.sort.trimmed.bam;
do
	gatk --java-options "-Xmx7g" HaplotypeCaller -I /mnt/tank/scratch/eraines/real_data_for_project/aligned/$file -R /mnt/tank/scratch/eraines/real_data_for_project/ref_genome/VITMroTrayshed_v2.0_hap1.fasta -ERC GVCF -O /mnt/tank/scratch/eraines/real_data_for_project/snp/"${file%%.*}".g.vcf.gz
done
###Apply CombineGVCFs
for file in snp/*.g.vcf.gz;
do
	gatk --java-options "-Xmx7g" CombineGVCFs -R /mnt/tank/scratch/santonec/real_data_for_project/ref_genome/VITMroTrayshed_v2.0_hap1.fasta -V $file
 -O /mnt/tank/scratch/santonec/real_data_for_project/lib1/cohort.g.vcf.gz

###Apply GenotypeGVCFs
for file in snp/*.g.vcf.gz;
do
	gatk --java-options "-Xmx7g" GenotypeGVCFs  -R /mnt/tank/scratch/santonec/real_data_for_project/ref_genome/VITMroTrayshed_v2.0_hap1.fasta -V /mnt/tank/scratch/santonec/real_data_for_project/lib1/cohort.g.vcf.gz -O /mnt/tank/scratch/santonec/real_data_for_project/lib1/output.vcf.gz
done