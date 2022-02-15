#!/bin/sh

#SBATCH --job-name=snpcalling
#SBATCH --time=50:00:00
#SBATCH --nodelist=meduza-2
#SBATCH --mem=100G

###FastQC, MultiQC
cd library/

for file in *.fq.gz;
do
	fastqc -o library/fastqc_before/ $file
done

multiqc library/fastqc_before/

###Trimming

for file in *.fq.gz;
do
	trimmomatic SE $file library/trimmed/"${file%%.*}".trimmed.fq.gz ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 SLIDINGWINDOW:4:15
done

###FastQC, MultiQC

for file in *.trimmed.fq.gz;
do
	fastqc -o library/fastqc_after_trimming/ $file
done

multiqc library/fastqc_after_trimming/

###Filtering reference file to include only hap1
cd Ref_genome/
grep -w 'hap1' VITMroTrayshed_v2.0.fasta > 
seqtk subseq library/Ref_genome/VITMroTrayshed_v2.0.fasta hap1.lst > /mnt/tank/scratch/santonec/real_data_for_project/ref_genome/VITMroTrayshed_v2.0_hap1.fasta

###GATK SNP calling.
###Index Regerence

bwa index library/Ref_genome/VITMroTrayshed_v2.0_hap1.fasta
samtools faidx library/Ref_genome/VITMroTrayshed_v2.0_hap1.fasta

gatk CreateSequenceDictionary -R library/Ref_genome/VITMroTrayshed_v2.0_hap1.fasta

### Alignment
cd ..
cd trimmed
for file in *.trimmed.fq.gz;
do
	bwa mem -M -t 2 -R "@RG\tID:SRR622461.7\tSM:$file\tLB:ERR194147\tPL:ILLUMINA" library/Ref_genome/VITMroTrayshed_v2.0_hap1.fasta library/trimmed/$file | samtools view -b -h -o library/aligned/"${file%%.*}".trimmed.bam
done

###QC after alignment
cd ..
cd aligned
for file in *.trimmed.bam;
do
	fastqc -o library/fastqc_aligned/ $file
done

multiqc library/fastqc_aligned/

### Sort sam
for file in *.trimmed.bam;
do
	picard -Xmx7g SortSam I=$file O="${file%%.*}".sort.trimmed.bam VALIDATION_STRINGENCY=LENIENT SORT_ORDER=coordinate CREATE_INDEX=True
done

###Index file
for file in *.sort.trimmed.bam;
do
	samtools index library/aligned/$file
done

###Variant calling
for file in *.sort.trimmed.bam;
do
	gatk --java-options "-Xmx7g" HaplotypeCaller -I library/aligned/$file -R library/Ref_genome/VITMroTrayshed_v2.0_hap1.fasta -ERC GVCF -O library/snp/"${file%%.*}".g.vcf.gz
done

###Apply CombineGVCFs
cd ..
cd snp
gatk --java-options "-Xmx7g" CombineGVCFs -R library/Ref_genome/VITMroTrayshed_v2.0_hap1.fasta -V 4_11_2_51.g.vcf.gz -V 4_11_2_52.g.vcf.gz ... 
 -O cohort.g.vcf.gz

###Apply GenotypeGVCFs
gatk --java-options "-Xmx7g" GenotypeGVCFs  -R library/Ref_genome/VITMroTrayshed_v2.0_hap1.fasta -V cohort.g.vcf.gz -O output.vcf.gz
