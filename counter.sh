
# for raw data. Process on raw data directory
for i in *.fq.gz;
do
        echo $i >> list_of_trimmed.txt
        zcat $i | echo $((`wc -l`/4)) >> list_of_reads2.txt
done


# for trimmed data. Process on trimmed data directory
for i in *.fq.gz;
do
        echo $i
        zcat $i | echo $((`wc -l`/4))
done



# for aligned data. Process on aligned data directory
for i in *.bam;
do

        samtools view -c -F 260 $i>> list_of_reads3.txt
done
