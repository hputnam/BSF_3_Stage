#!/bin/bash
#SBATCH --job-name="Reciprocal BLAST"
#SBATCH -t 1000:00:00
#SBATCH --export=NONE
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=erin_chille@uri.edu
#SBATCH -D /data/putnamlab/erin_chille/BSF_3_Stage/

echo "This script is meant to run on the URI Bluewaves server. \n To run on the Andromeda server, you may have to change the module versions"
echo "Loading modules" $(date)
module load blast/2.2.29+
module load Python/3.8.6-GCCcore-10.2.0
module load parallel/20190922-GCCcore-8.3.0
module load blast/2.2.29+
module load gffread/0.12.2-GCCcore-8.3.0
module load SAMtools/1.9-foss-2018b
module list

echo "Making an index for the genome fasta files to make it easier to parse them" $(date)
ls ../refs/*.fa | parallel samtools faidx '{}'

echo "Extracting developmental transcriptomes from Stringtie GFFs" $(date)

gffread --table @genename -w Pacu.fa -g ../refs/Pocillopora_acuta_genome_v1.fa ../Pacu/stringtie_out_files/Pacu.combined.gtf
cat Pacu.fa | sed 's/>.*\s/>/' > Pacuta_genes.fa #Replace transcript IDs with gene names
awk '/^>/ { f = !a[$0]++ } f' Pacuta_genes.fa > Pacu.fa #Remove dups
rm Pacuta_genes.fa

gffread --table @genename -w Mcap.fa -g ../refs/Mcap.genome_assembly.fa ../Mcap/stringtie_out_files/Mcap.combined.gtf
cat Mcap.fa | sed 's/>.*\s/>/' > Mcapitata_genes.fa #Replace transcript IDs with gene names
awk '/^>/ { f = !a[$0]++ } f' Mcapitata_genes.fa > Mcap.fa #Remove dups
rm Mcapitata_genes.fa

gffread --table @genename -w Spis.fa -g ../refs/Spis.genome.scaffold.final.fa ../Spis/stringtie_out_files/Spis.combined.gtf
cat Spis.fa | sed 's/>.*\s/>/' > Spistillata_genes.fa #Replace transcript IDs with gene names
awk '/^>/ { f = !a[$0]++ } f' Spistillata_genes.fa > Spis.fa #Remove dups
rm Spistillata_genes.fa

echo "Making a blast database for each species from their developmental transcriptomes" $(date)
makeblastdb -in Pacu.fa -input_type fasta -dbtype nucl -parse_seqids -out Pacu.tblastn.db
makeblastdb -in Mcap.fa -input_type fasta -dbtype nucl -parse_seqids -out Mcap.tblastn.db
makeblastdb -in Spis.fa -input_type fasta -dbtype nucl -parse_seqids -out Spis.tblastn.db

echo "Reciprocal blasting each species against each other so that at the end we have a table of reciprocal hits for each mutation of pairs" $(date)
tblastn -query refs/Mcap.protein.fa -db ortho_search/Pacu.tblastn.db -outfmt 0 -evalue 1e-05 -out ortho_search/Mcap_v_Pacu
tblastn -query refs/Mcap.protein.fa -db ortho_search/Spis.tblastn.db -outfmt 0 -evalue 1e-05 -out ortho_search/Mcap_v_Spis
tblastn -query refs/Pacu.protein.fa -db ortho_search/Mcap.tblastn.db -outfmt 0 -evalue 1e-05 -out ortho_search/Pacu_v_Mcap
tblastn -query refs/Pacu.protein.fa -db ortho_search/Spis.tblastn.db -outfmt 0 -evalue 1e-05 -out ortho_search/Pacu_v_Spis
tblastn -query refs/Spis.protein.fa -db ortho_search/Mcap.tblastn.db -outfmt 0 -evalue 1e-05 -out ortho_search/Spis_v_Mcap
tblastn -query refs/Spis.protein.fa -db ortho_search/Pacu.tblastn.db -outfmt 0 -evalue 1e-05 -out ortho_search/Spis_v_Pacu

echo "Removing 'lcl|' and space from between > and gene_id" "$(date)"
mv ./Spis_v_Mcap ./Spis_v_Mcap1
sed -e '/^>/s/lcl|/ /' Spis_v_Mcap1 > Spis_v_Mcap
gunzip Spis_v_Mcap1
mv ./Mcap_v_Spis ./Mcap_v_Spis1
sed -e '/^>/s/lcl|/ /' Mcap_v_Spis1 > Mcap_v_Spis
rm Mcap_v_Spis1

mv ./Mcap_v_Pacu ./Mcap_v_Pacu1
sed -e '/^>/s/lcl|/ /' Mcap_v_Pacu1 > Mcap_v_Pacu
gunzip Mcap_v_Pacu1
mv ./Pacu_v_Mcap ./Pacu_v_Mcap1
sed -e '/^>/s/lcl|/ /' Pacu_v_Mcap1 > Pacu_v_Mcap
rm Pacu_v_Mcap1

mv ./Spis_v_Pacu ./Spis_v_Pacu1
sed -e '/^>/s/lcl|/ /' Spis_v_Pacu1 > Spis_v_Pacu
gunzip Spis_v_Pacu1
mv ./Pacu_v_Spis ./Pacu_v_Spis1
sed -e '/^>/s/lcl|/ /' Pacu_v_Spis1 > Pacu_v_Spis
rm Pacu_v_Spis1

echo "Running Transcriptolog python script to verify orthologs"
echo "Transcriptologs: A Transcriptome-Based Approach to Predict Orthology Relationships; DOI 10.1177/1177932217690136"
echo "Obtained from curl -O https:/raw.githubusercontent.com/LucaAmbrosino/Transcriptologs/master/transcriptologs.py"
./transcriptologs.py -i1 Mcap_v_Pacu -i2 Pacu_v_Mcap -o Mcap_Pacu_orthologues.tsv
./transcriptologs.py -i1 Pacu_v_Spis -i2 Spis_v_Pacu -o Pacu_Spis_orthologues.tsv
./transcriptologs.py -i1 Mcap_v_Spis -i2 Spis_v_Mcap -o Spis_Mcap_orthologues.tsv