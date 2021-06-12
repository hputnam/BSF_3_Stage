#!/bin/bash
#SBATCH --job-name="initQC"
#SBATCH -t 100:00:00
#SBATCH --export=NONE
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=XXX
#SBATCH --mem=128GB
#SBATCH -D XXX

##This script is to quality assess and clean RNA sequences from three life stages of three coral species
#https://github.com/hputnam/BSF_3_Stage
#FastQ sequences from 9 samples representing, 3 biological reps each
# P. acuta ENA Project PRJNA306839 (https://www.ebi.ac.uk/ena/browser/view/PRJNA306839); SE 151 bp Miseq
# S. pistillata ENA Project PRJNA725478 (https://www.ebi.ac.uk/ena/browser/view/PRJNA725478) PE 156 bp Hiseq
# M. capitata ENA Project (TBD; Link) PE 150 bp Hiseq

#RUN 1x for each species.

echo "Loading programs" $(date)

#Load programs for bioinformatic analysis
module load FastQC/0.11.8-Java-1.8 #Quality check: FastQC
module load MultiQC/1.7-foss-2018b-Python-2.7.15 #Quality check: MultiQC
module list

echo "Downloading raw read (fastq) files" $(date)

#Download fastq files 

# S. pistallata
curl https://sra-download.ncbi.nlm.nih.gov/traces/sra74/SRZ/014333/SRR14333319/IIId_f.fastq.gz > Spis/raw_reads/SRR14333319_R1.fastq.gz
curl https://sra-download.ncbi.nlm.nih.gov/traces/sra74/SRZ/014333/SRR14333319/IIId_r.fastq.gz > Spis/raw_reads/SRR14333319_R2.fastq.gz

curl https://sra-download.ncbi.nlm.nih.gov/traces/sra38/SRZ/014333/SRR14333320/IIIb_f.fastq.gz > Spis/raw_reads/SRR14333320_R1.fastq.gz
curl https://sra-download.ncbi.nlm.nih.gov/traces/sra38/SRZ/014333/SRR14333320/IIIb_r.fastq.gz > Spis/raw_reads/SRR14333320_R2.fastq.gz

curl https://sra-download.ncbi.nlm.nih.gov/traces/sra60/SRZ/014333/SRR14333321/IIIa_f.fastq.gz > Spis/raw_reads/SRR14333321_R1.fastq.gz
curl https://sra-download.ncbi.nlm.nih.gov/traces/sra60/SRZ/014333/SRR14333321/IIIa_r.fastq.gz > Spis/raw_reads/SRR14333321_R2.fastq.gz

curl https://sra-download.ncbi.nlm.nih.gov/traces/sra13/SRZ/014333/SRR14333322/IIe_f.fastq.gz > Spis/raw_reads/SRR14333322_R1.fastq.gz
curl https://sra-download.ncbi.nlm.nih.gov/traces/sra13/SRZ/014333/SRR14333322/IIe_r.fastq.gz > Spis/raw_reads/SRR14333322_R2.fastq.gz

curl https://sra-download.ncbi.nlm.nih.gov/traces/sra77/SRZ/014333/SRR14333323/IId_f.fastq.gz > Spis/raw_reads/SRR14333323_R1.fastq.gz
curl https://sra-download.ncbi.nlm.nih.gov/traces/sra77/SRZ/014333/SRR14333323/IId_r.fastq.gz > Spis/raw_reads/SRR14333323_R1.fastq.gz

curl https://sra-download.ncbi.nlm.nih.gov/traces/sra70/SRZ/014333/SRR14333324/IIb_f.fastq.gz > Spis/raw_reads/SRR14333324_R1.fastq.gz
curl https://sra-download.ncbi.nlm.nih.gov/traces/sra70/SRZ/014333/SRR14333324/IIb_r.fastq.gz > Spis/raw_reads/SRR14333324_R2.fastq.gz

curl https://sra-download.ncbi.nlm.nih.gov/traces/sra38/SRZ/014333/SRR14333325/Ig_f.fastq.gz > Spis/raw_reads/SRR14333325_R1.fastq.gz
curl https://sra-download.ncbi.nlm.nih.gov/traces/sra38/SRZ/014333/SRR14333325/Ig_r.fastq.gz > Spis/raw_reads/SRR14333325_R2.fastq.gz

curl https://sra-download.ncbi.nlm.nih.gov/traces/sra52/SRZ/014333/SRR14333326/Id_f.fastq.gz > Spis/raw_reads/SRR14333326_R1.fastq.gz
curl https://sra-download.ncbi.nlm.nih.gov/traces/sra52/SRZ/014333/SRR14333326/Id_r.fastq.gz > Spis/raw_reads/SRR14333326_R2.fastq.gz

curl https://sra-download.ncbi.nlm.nih.gov/traces/sra70/SRZ/014333/SRR14333327/Ic_f.fastq.gz > Spis/raw_reads/SRR14333327_R1.fastq.gz
curl https://sra-download.ncbi.nlm.nih.gov/traces/sra70/SRZ/014333/SRR14333327/Ic_r.fastq.gz > Spis/raw_reads/SRR14333327_R2.fastq.gz

# P. acuta
curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/003/SRR3051863/SRR3051863.fastq.gz > Pacu/raw_reads/SRR3051863.fastq.gz
curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/004/SRR3051864/SRR3051864.fastq.gz > Pacu/raw_reads/SRR3051864.fastq.gz
curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/005/SRR3051865/SRR3051865.fastq.gz > Pacu/raw_reads/SRR3051865.fastq.gz
curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/006/SRR3051866/SRR3051866.fastq.gz > Pacu/raw_reads/SRR3051866.fastq.gz
curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/007/SRR3051867/SRR3051867.fastq.gz > Pacu/raw_reads/SRR3051867.fastq.gz
curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/008/SRR3051868/SRR3051868.fastq.gz > Pacu/raw_reads/SRR3051868.fastq.gz
curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/009/SRR3051869/SRR3051869.fastq.gz > Pacu/raw_reads/SRR3051869.fastq.gz
curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/000/SRR3051870/SRR3051870.fastq.gz > Pacu/raw_reads/SRR3051870.fastq.gz
curl ftp.sra.ebi.ac.uk/vol1/fastq/SRR305/001/SRR3051871/SRR3051871.fastq.gz > Pacu/raw_reads/SRR3051871.fastq.gz

#Initial Quality Assessment and Read Trimming

echo "Starting assessment of raw reads" $(date)

ls -1 Spis/raw_reads/*.fastq.gz | wc -l #Check to make sure you have 18 files
ls -1 Pacu/raw_reads/*.fastq.gz | wc -l #Check to make sure you have 9 files

md5sum Spis/raw_reads/*.fastq.gz > Spis/raw_reads/raw_checksum.md5 #Make sure files have downloaded correctly. Store the md5sum in a file
md5sum -c Spis/raw_reads/raw_checksum.md5 #Verify the contents are "All OK"
md5sum Pacu/raw_reads/*.fastq.gz > Pacu/raw_reads/raw_checksum.md5 #Make sure files have downloaded correctly. Store the md5sum in a file
md5sum -c Pacu/raw_reads/raw_checksum.md5 #Verify the contents are "All OK"

zgrep -c "@SRR" Spis/raw_reads/*.fastq.gz #Check the number of reads per file
zgrep -c "@D00" Pacu/raw_reads/*.fastq.gz #Check the number of reads per Spis file

fastqc Spis/raw_reads/*.fastq.gz #Run FastQC in the raw directory
fastqc Pacu/raw_reads/*.fastq.gz #Run FastQC in the raw directory

multiqc ./Pacu/raw_reads/ #Compile MultiQC report from FastQC files
multiqc ./Spis/raw_reads/ #Compile MultiQC report from FastQC files

echo "Assessment of raw reads complete" $(date)
