#!/bin/bash
#SBATCH --job-name="stringtie"
#SBATCH -t 100:00:00
#SBATCH --export=/opt/software/StringTie/2.1.4-GCC-9.3.0/bin/prepDE.py
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=erin_chille@uri.edu
#SBATCH --exclusive
#SBATCH --nodes 1 --ntasks-per-node=20
#SBATCH --mem=500GB
#SBATCH -D /data/putnamlab/erin_chille/BSF_3_Stage/Spis/hisat2_bam

##This script is to assemble and quantify gene counts from the RNA sequences of three life stages of three coral species to respective genome assemblies
#https://github.com/hputnam/BSF_3_Stage
#FastQ sequences from 9 samples representing, 3 biological reps each
# P. acuta ENA Project PRJNA306839 (https://www.ebi.ac.uk/ena/browser/view/PRJNA306839)
# S. pistillata ENA Project PRJNA725478 (https://www.ebi.ac.uk/ena/browser/view/PRJNA725478)
# M. capitata ENA Project (TBD; Link)

echo "Loading programs" $(date)
module load StringTie/2.1.4-GCC-9.3.0 #Transcript assembly: StringTie
module load gffcompare/0.11.5-foss-2018b #Transcript assembly QC: GFFCompare
module list

#StringTie reference-guided assembly

echo "Starting assembly!" $(date)

array3=($(ls *.bam)) #Make an array of sequences to assemble
for i in ${array3[@]}; do #Running with the -e option to compare output to exclude novel genes. Also output a file with the gene abundances
        stringtie -p $SLURM_NTASKS_PER_NODE -e -G ../ref/Spis.genome.annotation.gff3 -o ../stringtie_out_files/${i}.gtf ${i}
        echo "StringTie-assembly-to-ref ${i}" $(date)
done
echo "Assembly complete! Starting assembly analysis..." $(date)

cd /data/putnamlab/erin_chille/BSF_3_Stage/Spis/stringtie_out_files #change working dir

stringtie --merge -p $SLURM_NTASKS_PER_NODE -G ../ref/Spis.genome.annotation.gff3 -o Spis_merged.gtf ../stringtie_mergelist.txt #Merge GTFs to form full GTF for analysis of assembly accuracy and precision
echo "Stringtie merge complete" $(date)

gffcompare -r ../ref/Spis.genome.annotation.gff3 -G -o Spris_merged Spis_merged.gtf #Compute the accuracy and precision of assembly
echo "GFFcompare complete! Starting gene count matrix assembly..." $(date)

python /opt/software/StringTie/2.1.4-GCC-9.3.0/bin/prepDE.py -g Spis_gene_count_matrix.csv -i ../stringtie_samplelist.txt #Compile the gene count matrix