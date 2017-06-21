#!/bin/bash

#$ -S /bin/bash
#$ -l h_vmem=8G
#$ -l h_rt=30:00:00
#$ -l h_cpu=30:00:00
#$ -j y
#$ -o /nrnb/users/abuckley/EXAC/out
#$ -N LOFTEE
#$ -pe smp 2

# location of VEP and LOFTEE files
veppath="/nrnb/users/abuckley/tools/ensembl-tools-release-81/scripts/variant_effect_predictor"

# location of VEP pipeline scripts
scriptpath="/cellar/users/abuckley/github_scripts/annotation"
vcf="INS_VCF"
out="${vcf}.LOFTEE"

# Launch VEP with LOFTEE plugin
perl ${veppath}/variant_effect_predictor.pl \
      -i ${vcf} \
      -o ${out}  \
      --dir_plugins ~/.vep/Plugins/ --offline --cache_version 85	 \
      --force_overwrite --fasta ${veppath}/hs37d5.fa \
       --plugin LoF,human_ancestor_fa:~/.vep/Plugins/human_ancestor.fa.rz \


source activate py27

# parse LOFTEE output
python ${scriptpath}/parse.LOFTEE.py ${out} ${out}.tmp

# remove dupilcates
sort -k1,1 -k 2,2 -V -s ${out}.tmp | uniq >  ${out}.parse

rm ${out}.tmp
