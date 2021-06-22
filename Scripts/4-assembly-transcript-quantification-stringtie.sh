#!/bin/bash
#SBATCH --job-name="stringtie"
#SBATCH -t 100:00:00
#SBATCH --export=/opt/software/StringTie/2.1.4-GCC-9.3.0/bin/prepDE.py
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=XXX
#SBATCH --exclusive
#SBATCH --nodes 1 --ntasks-per-node=20
#SBATCH --mem=500GB
#SBATCH -D Spis/hisat2_bam

##This script is to assemble and quantify gene counts from the RNA sequences of three life stages of three coral species to respective genome assemblies
#https://github.com/hputnam/BSF_3_Stage
#FastQ sequences from 9 samples representing, 3 biological reps each
# P. acuta ENA Project PRJNA306839 (https://www.ebi.ac.uk/ena/browser/view/PRJNA306839)
# S. pistillata ENA Project PRJNA725478 (https://www.ebi.ac.uk/ena/browser/view/PRJNA725478)
# M. capitata ENA Project (TBD; Link)

echo "Loading programs" $(date)
module load StringTie/2.1.3-GCC-8.3.0 #Transcript assembly: StringTie
module load GffCompare/0.12.1-GCCcore-8.3.0 #Transcript assembly QC: GFFCompare
module list

#StringTie reference-guided assembly

echo "Starting assembly!" $(date)

array1=($(ls *.bam)) #Make an array of sequences to assemble
for i in ${array1[@]}; do 
	stringtie -p $SLURM_NTASKS_PER_NODE -e --conservative -C ../stringtie_out_files/$(echo ${i}|sed s/.fastq.gz.bam/_coverage/) -G ../ref/Spis.genome.annotation.gff3 -o ../stringtie_out_files/${i}.gtf ${i}
    grep -c "transcript" ../stringtie_out_files/$(echo ${i}|sed s/.fastq.gz.bam/_coverage.gtf/)
	zgrep -c "exon" ../stringtie_out_files/$(echo ${i}|sed s/.fastq.gz.bam/_coverage.gtf/)
	echo "StringTie-assembly-to-ref ${i}" $(date)
done
#Running with the -e option to compare output to exclude novel genes. Also outputs GTF file for each assembly containing only sequences with full coverage
#Out file prints the number of fully covered transcripts and exons, respectively 

echo "Assembly complete! Starting assembly evaluation." $(date)

cd Spis/stringtie_out_files #change working dir

gffcompare -r ../ref/Spis.genome.annotation.gff3 -R -G -V -o Spis -i ../stringtie_mergelist.txt #Compute the accuracy and precision of assembly
	
        # -r = Reference
        # -R = Ignore reference sequences with no aligned transcripts in any 1 sample to calculate sensitivity
        # -Q = Ignore reference sequences with no aligned transcripts in all samples to calculate sensitivity
        # -V = Verbose mode
        # -o = output prefix is sample ID
        # -i = text file with query file paths

echo "Assessment of GTFs complete! Starting gene count matrix assembly." $(date)
python /opt/software/StringTie/2.1.4-GCC-9.3.0/bin/prepDE.py -g Spis_gene_count_matrix.csv -i ../stringtie_samplelist.txt #Compile the gene count matrix