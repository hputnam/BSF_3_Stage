#!/bin/bash
#SBATCH --job-name="trimQC"
#SBATCH -t 100:00:00
#SBATCH --export=NONE
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=XXX
#SBATCH --mem=128GB
#SBATCH -D XXX

##This script is quality trim and subsequently QCSE RNA sequences from three life stages of three coral species
#https://github.com/hputnam/BSF_3_Stage
#FastQ sequences from 9 samples representing, 3 biological reps each
# P. acuta ENA Project PRJNA306839 (https://www.ebi.ac.uk/ena/browser/view/PRJNA306839)
# S. pistillata ENA Project PRJNA725478 (https://www.ebi.ac.uk/ena/browser/view/PRJNA725478)
# M. capitata ENA Project (TBD; Link)

echo "Loading programs" $(date)

#Load programs for bioinformatic analysis
#module load Python/2.7.15-foss-2018b #Python
module load FastQC/0.11.8-Java-1.8 #Quality check: FastQC
module load MultiQC/1.7-foss-2018b-Python-2.7.15 #Quality check: MultiQC
module load fastp/0.19.7-foss-2018b #Quality trimming: Fastp
module list

echo "Starting read trimming." $(date)

cd raw_reads #move to correct dir
array1=($(ls *_R1.fastq.gz)) #Make an array of sequences to trim

for i in ${array1[@]}; do #Make a loop that trims each file in the array PAIRED END (Mcap and Spis)
         fastp --in1 ${i} --in2 $(echo ${i}|sed s/_R1/_R2/) --out1 ../clean_reads/${i} --out2 ../clean_reads/$(echo ${i}|sed s/_R1/_R2/) --detect_adapter_for_pe \
         --qualified_quality_phred 20 --unqualified_percent_limit 10 --cut_right cut_right_window_size 5 cut_right_mean_quality 20 \
         -h ../clean_reads/${i}.fastp.html -j ../clean_reads/${i}.fastp.json
done

for i in ${array1[@]}; do #Make a loop that trims each file in the array SINGLE END (Pacu)
         fastp --in1 ${i} --out1 ../clean_reads/${i}
         --qualified_quality_phred 20 --unqualified_percent_limit 10 --cut_right cut_right_window_size 5 cut_right_mean_quality 20 \
         -h ../clean_reads/${i}.fastp.html -j ../clean_reads/${i}.fastp.json
done

echo "Read trimming complete. Starting assessment of clean reads." $(date)

cd ../clean_reads #move to correct dir
fastqc ./*.fastq.gz
multiqc ./ #Compile MultiQC report from FastQC files

echo "Cleaned MultiQC report generated. Have a look-see at the results while the number of reads per sequence is tabulated" $(date)

echo "Assessment of trimmed reads complete" $(date)
