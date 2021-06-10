#!/bin/bash
#SBATCH --job-name="trimQC"
#SBATCH -t 100:00:00
#SBATCH --export=NONE
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=XXXX
#SBATCH --mem=128GB
#SBATCH -D XXXXX

##This script is quality trim and subsequently QCSE RNA sequences from three life stages of three coral species
#https://github.com/hputnam/BSF_3_Stage
#FastQ sequences from 9 samples representing, 3 biological reps each
# P. acuta ENA Project PRJNA306839 (https://www.ebi.ac.uk/ena/browser/view/PRJNA306839)
# S. pistillata ENA Project PRJNA725478 (https://www.ebi.ac.uk/ena/browser/view/PRJNA725478)
# M. capitata ENA Project (TBD; Link)
#CHANGE PATH LINES 29,39

echo "Loading programs" $(date)

#Load programs for bioinformatic analysis
#module load Python/2.7.15-foss-2018b #Python
module load FastQC/0.11.8-Java-1.8 #Quality check: FastQC
module load MultiQC/1.7-foss-2018b-Python-2.7.15 #Quality check: MultiQC
module load fastp/0.19.7-foss-2018b #Quality trimming: Fastp
module list

echo "Starting read trimming." $(date)

cd XXXX/raw_reads #move to correct dir CHANGE DIR
array1=($(ls *.fastq.gz)) #Make an array of sequences to trim

for i in ${array1[@]}; do #Make a loop that trims each file in the array
         fastp --in1 ${i} --out1 ../clean_reads/${i} --qualified_quality_phred 20 --unqualified_percent_limit 10 --length_required 25 --cut_right cut_right_window_size 5 cut_right_mean_quality 20 -h ../clean_reads/${i}.fastp.html -j ../clean_reads/${i}.fastp.json
         fastqc ../clean_reads/${i}
done

echo "Read trimming complete. Starting assessment of clean reads." $(date)

cd XXXX/clean_reads #move to correct dir CHANGE DIR
multiqc ./ #Compile MultiQC report from FastQC files

echo "Cleaned MultiQC report generated. Have a look-see at the results while the number of reads per sequence is tabulated" $(date)

zgrep -c "@SRR" *.fastq.gz #Check the number of reads per file again

echo "Assessment of trimmed reads complete" $(date)
