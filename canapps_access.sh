#!/bin/bash
# coding=utf-8
# author:       Máire Ní Leathlobhair (ml677@cam.ac.uk)
# date:         May 2016
# description:  Automates bam file downloads using path specified in Canapps

print_help() {
    echo
    echo
    echo "| Canapps Access script"
    echo "|"
    echo "| Maire Ni Leathlobhair"
    echo "| Transmissible Cancer Group, University of Cambridge 2016"
    echo "|"
    echo "| Script automates process of downloading data using input file containing list of sample IDs "
    echo "|"    
    echo "| Input:"
    echo "|    -i  Absolute path to folder where bam files should be copied"
    echo "|    -t  Text file containing list of sample IDs"
    echo "|    -p  Canapps project ID."
    echo "|"
    echo "| Usage:"
    echo "|    somatypus -i /path/for/bams -t sample_ids.txt -p XXXX"
    echo
    echo
}
# If no arguments (or -h): print help
if [ "$#" -eq 0 ]; then
    print_help
    exit 0
fi

function canapps_download()
{
	mkdir ${1}/NO_DUPLICATES
	bams_to_download=($(more ${2}))
	for a in "${bams_to_download[@]}";
		do
		#if bam file does not exist then download it else print message to user
		if [ ! -f ${1}/${a}.bam ]; then
			####download bam file
			download_bam=$(pipelineResult -db live -p ${3} -s $a -t 247)
			echo -e "\n(1) COPYING ${a}.bam FROM CANAPPS\n" 
			cp $download_bam ${1}/"$a".bam
			####download indexed bam
			download_index=$(pipelineResult -db live -p ${3} -s $a -t 16)
			echo -e "\n(2) COPYING ${a}.bam.bai FROM CANAPPS \n"       
			cp $download_index ${1}/"$a".bam.bai
		else 
			echo "Bam file ${a}.bam already exists."
		fi
		echo -e "\n(3) REMOVING DUPLICATES FROM ${a}.bam \n"
		samtools rmdup ${1}/${a}.bam ${1}/NO_DUPLICATES/${a}.duplicates_removed.bam
		samtools index ${1}/NO_DUPLICATES/${a}.duplicates_removed.bam
		done
		echo -e "\nALL DONE!"
}

canapps_download ${1} ${2} ${3}
