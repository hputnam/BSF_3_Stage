#!/bin/bash
#SBATCH --job-name="initQC"
#SBATCH -t 100:00:00
#SBATCH --export=NONE
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=XXXXXXX
#SBATCH --mem=128GB
#SBATCH -D XXXXXXX

##This script is to quality assess and clean SE RNA sequences from three life stages of three coral species
#https://github.com/hputnam/BSF_3_Stage
#FastQ sequences from 9 samples representing, 3 biological reps each
# P. acuta ENA Project PRJNA306839 (https://www.ebi.ac.uk/ena/browser/view/PRJNA306839)
# S. pistillata ENA Project PRJNA725478 (https://www.ebi.ac.uk/ena/browser/view/PRJNA725478)
# M. capitata ENA Project (TBD; Link)

echo "Loading programs" $(date)

#Load programs for bioinformatic analysis
module load FastQC/0.11.8-Java-1.8 #Quality check: FastQC
module load MultiQC/1.7-foss-2018b-Python-2.7.15 #Quality check: MultiQC
module list

echo "Downloading raw read (fastq) files" $(date)

#Download fastq files 

# P. acuta
#curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/003/SRR3051863/SRR3051863.fastq.gz > raw_reads/SRR3051863.fastq.gz
#curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/004/SRR3051864/SRR3051864.fastq.gz > raw_reads/SRR3051864.fastq.gz
#curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/005/SRR3051865/SRR3051865.fastq.gz > raw_reads/SRR3051865.fastq.gz
#curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/006/SRR3051866/SRR3051866.fastq.gz > raw_reads/SRR3051866.fastq.gz
#curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/007/SRR3051867/SRR3051867.fastq.gz > raw_reads/SRR3051867.fastq.gz
#curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/008/SRR3051868/SRR3051868.fastq.gz > raw_reads/SRR3051868.fastq.gz
#curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/009/SRR3051869/SRR3051869.fastq.gz > raw_reads/SRR3051869.fastq.gz
#curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/000/SRR3051870/SRR3051870.fastq.gz > raw_reads/SRR3051870.fastq.gz
#curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/001/SRR3051871/SRR3051871.fastq.gz > raw_reads/SRR3051871.fastq.gz

#Initial Quality Assessment and Read Trimming

cd raw_reads #The following commands will be run in the amil/raw directory

echo "Starting assessment of raw reads" $(date)

ls -1 *.fastq.gz | wc -l #Check to make sure you have 9 files

md5sum *.fastq.gz > raw_checksum.md5 #Make sure files have downloaded correctly. Store the md5sum in a file
md5sum -c raw_checksum.md5 #Verify the contents are "All OK"

zgrep -c "@SRR" *fastq.gz #Check the number of reads per file

fastqc *.fastq.gz #Run FastQC in the raw directory
multiqc ./ #Compile MultiQC report from FastQC files

echo "Assessment of raw reads complete" $(date)
