#!/bin/bash
#SBATCH --job-name="ref"
#SBATCH -t 100:00:00
#SBATCH --export=NONE
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=XXX
#SBATCH -D XXX/ref

##This script is to quality assess and clean RNA sequences from three life stages of three coral species
#https://github.com/hputnam/BSF_3_Stage
#FastQ sequences from 9 samples representing, 3 biological reps each
# P. acuta ENA Project PRJNA306839 (https://www.ebi.ac.uk/ena/browser/view/PRJNA306839); SE 150 bp Miseq
# S. pistillata ENA Project PRJNA725478 (https://www.ebi.ac.uk/ena/browser/view/PRJNA725478) PE 150 bp Hiseq
# M. capitata ENA Project (TBD; Link) PE 150 bp Hiseq

echo "Loading programs" $(date)

#Load programs for bioinformatic analysis
module load HISAT2/2.1.0-foss-2018b #Indexing ref for alignment: HISAT2
module list

echo "Downloading reference genome" $(date)

#Download ref files 
curl -o - http://spis.reefgenomics.org/download/Spis.genome.scaffold.final.fa.gz | gunzip > Spis.genome.scaffold.final.fa

echo "Downloading reference complete. Indexing for alignment with HISAT2." $(date)
hisat2-build -f Spis.genome.scaffold.final.fa ./Spis_ref
echo "Index complete" $(date)