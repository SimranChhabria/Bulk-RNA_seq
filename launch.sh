#!/bin/bash
## number of cores
#SBATCH -n 8
#SBATCH -o RNA-seq.out


#----
# conda activate RNA_seq
#----

#----
#-- PATHS 
#----


FASTQ_DIR=/rugpfs/fs0/tavz_lab/scratch/schhabria/RNA_test/fastq
REF_DIR=/rugpfs/fs0/tavz_lab/scratch/schhabria/ref_files/mouse_ref/salmon_gencode.vM33.index/

RESULTS_DIR=/rugpfs/fs0/tavz_lab/scratch/schhabria/RNA_test/results

#---
#-- Parameter
#---

species="mm10"
ALIGNER="salmon"

READS="paired"

#---
#-- Launch the bash script
#---

bash /ru-auth/local/home/schhabria/pipelines/github_SC/RNA_GH/RNA_seq.sh $FASTQ_DIR $REF_DIR $RESULTS_DIR $species $ALIGNER $READS
