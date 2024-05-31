#!/bin/bash
#SBATCH -o RNA_seq.out

#----
# conda activate RNA-seq
#----

#---
# PATHS
#----

FASTQ_DIR="$1"
INDEX_PATH="$2"
RESULTS_DIR="$3"


#---
# Type of alignment : salmon or STAR
#---
SPECIES="$4"
ALIGNER="$5"


#---
# Reads type : single or paired reads
#--- 
READS="$6"

#--
# Outputs
#--

mkdir -p "$RESULTS_DIR"

FASTQC_DIR=$RESULTS_DIR/fastQC 
QUANT_DIR="$RESULTS_DIR/$ALIGNER"

mkdir -p "$FASTQC_DIR"
mkdir -p "$QUANT_DIR"

# ----
# Step 1: Run fastQC on the fastq files 
# ----
# Input: fastq.gz
# Output: fastqc.html
#----- 

# cd $FASTQ_DIR
# for fastq in *.fq.gz; 
#    do  
#     samplename=${fastq%.fq.gz}
#     echo "Processing sample ${fastq}"
#     echo "Sample name ${samplename}"
#     mkdir -p $FASTQC_DIR
#     fastqc -o $FASTQC_DIR $fastq   
# done


#----
#-- Step 2: Salmon alignment
#---
# Input : fastq.gz
# Output: quant.sf
#----

if [[ "$ALIGNER" == "salmon" ]]; then
    cd "$FASTQ_DIR"
    if [[ "$READS" == "single" ]]; then
        for fn in *_1.fq.gz; do
            samplename=${fn%_1.fq.gz}
            echo "Processing sample ${samplename}"
            salmon quant -i "$INDEX_PATH" -l A \
                --validateMappings \
                -r "$fn" \
                -p 8 -o "$QUANT_DIR/${samplename}"
        done
    elif [[ "$READS" == "paired" ]]; then
        for read1 in *_*_1.fq.gz; do
            read2=${read1/_1.fq.gz/_2.fq.gz}
            samplename=${read1%_1.fq.gz}
            echo "Processing sample ${samplename}"
            salmon quant -i "$INDEX_PATH" -l A \
                --validateMappings \
                -1 "$read1" -2 "$read2" \
                -p 8 -o "$QUANT_DIR/${samplename}"
        done
    fi


#----
#-- Step 2: STAR alignment
#---
# Input : fastq.gz
# Output: sample.bam
#----

elif [[ "$ALIGNER" == "STAR" ]]; then
    cd "$FASTQ_DIR"
    if [[ "$READS" == "single" ]]; then
        for fn in *_1.fq.gz; do
            samplename=${fn%_1.fq.gz}
            echo "Processing sample ${sample}"
            STAR --genomeDir "$INDEX_PATH" --runThreadN 8 --outFileNamePrefix "$QUANT_DIR/bams/${samplename}." \
                --readFilesIn "$fn" --outSAMtype BAM SortedByCoordinate --outSAMunmapped Within --outSAMattributes Standard --readFilesCommand zcat
            echo "STAR for ${samplename} done!"
        done
    elif [[ "$READS" == "paired" ]]; then
        for read1 in *_1.fq.gz; do
            samplename=${read1%_1.fq.gz}
            read2=${read1/_1.fq.gz/_2.fq.gz}
            echo "Processing sample ${samplename}"
            STAR --genomeDir "$INDEX_PATH" --runThreadN 8 --outFileNamePrefix "$QUANT_DIR/bams/${samplename}." \
                --readFilesIn "$read1" "$read2" --outSAMtype BAM SortedByCoordinate --outSAMunmapped Within --outSAMattributes Standard --readFilesCommand zcat
            echo "STAR for ${samplename} done!"
        done
    fi

    cd "$$QUANT_DIR/bams"
    featureCounts  -a $GTF_FILE -t exon -g gene_id -o $QUANT_DIR/read_counts.txt

fi
