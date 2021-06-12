#!/bin/bash
#SBATCH --job-name="hisat2"
#SBATCH -t 100:00:00
#SBATCH --export=NONE
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=XXX
#SBATCH --exclusive
#SBATCH --nodes 1 --ntasks-per-node=20
#SBATCH --mem=500GB
#SBATCH -D XXX/clean_reads

##This script is to align RNA sequences from three life stages of three coral species to respective genome assemblies
#https://github.com/hputnam/BSF_3_Stage
#FastQ sequences from 9 samples representing, 3 biological reps each
# P. acuta ENA Project PRJNA306839 (https://www.ebi.ac.uk/ena/browser/view/PRJNA306839)
# S. pistillata ENA Project PRJNA725478 (https://www.ebi.ac.uk/ena/browser/view/PRJNA725478)
# M. capitata ENA Project (TBD; Link)

echo "Loading programs" $(date)
module load HISAT2/2.1.0-foss-2018b #Alignment to reference genome: HISAT2
module load SAMtools/1.9-foss-2018b #Preparation of alignment for assembly: SAMtools

#-------------------------------------------------------

echo "Aligning single end reads" $(date) #Pacu

# Align reads to the indexed reference files (0-download-ref-files.sh) and save alignments in sam format.
# This then makes it into a bam file
# And then also sorts the bam file because Stringtie takes a sorted file for input
# And then removes the sam file because I don't need it anymore
array2=($(ls *.fastq.gz)) #Make an array of sequences to align
for i in ${array2[@]}; do
		echo "Starting alignment of sample ${i}" $(date)
        hisat2 -p $SLURM_NTASKS_PER_NODE --dta -q -x ref -U ${i} -S ${i}.sam
        samtools sort -@ $SLURM_NTASKS_PER_NODE -o ${i}.bam ${i}.sam
        echo "${i}_bam"
        rm ${i}.sam
        echo "HISAT2 complete for ${i}" $(date)
done
echo "HISAT2 complete. Now we can assemble!" $(date)

#-------------------------------------------------------

echo "Aligning paired end reads" $(date) #Spis and Mcap

# Align reads to the indexed reference files (0-download-ref-files.sh) and save alignments in sam format.
#Has the R1 in array1 because the sed in the for loop changes it to an R2. SAM files are of both forward and reverse reads.
array1=($(ls *_R1.fastq.gz))

# This then makes it into a bam file
# And then also sorts the bam file because Stringtie takes a sorted file for input
# And then removes the sam file because I don't need it anymore

for i in ${array1[@]}; do
		echo "Starting alignment of sample $(echo ${i}|sed s/_R1//)" $(date)
        hisat2 -p $SLURM_NTASKS_PER_NODE --rf --dta -q -x ref -1 ${i} -2 $(echo ${i}|sed s/_R1/_R2/) -S $(echo ${i}|sed s/_R1//).sam
        samtools sort -@ $SLURM_NTASKS_PER_NODE -o ../hisat2_bam/$(echo ${i}|sed s/_R1//).bam $(echo ${i}|sed s/_R1//).sam
    	echo "$(echo ${i}|sed s/_R1//)_bam"
        rm $(echo ${i}|sed s/_R1//).sam
        echo "HISAT2 complete for $(echo ${i}|sed s/_R1//)" $(date)
done

echo "HISAT2 complete. Now we can assemble!" $(date)