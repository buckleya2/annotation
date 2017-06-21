## Bash script that generates LOFTEE annotation scripts
## One job per chromosome
## Takes in file with chr,pos,ref,alt to annotate, a prefix for outfiles, and an output filepath

infile=$1
prefix=$2
filepath=$3

# directory where generic VEP script is
scriptpath="/cellar/users/abuckley/github_scripts/annotation"

#For each chromosome, generate a vcf-like file to input to VEP
echo -e "1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n13\n14\n15\n16\n17\n18\n19\n20\n21\n22\nX\nY" > chromosome
while read i
do
echo $i
awk -v OFS='\t' -v chrom=$i '{if ($1 == chrom) {print $1, $2, 0, $3, $4, 0,0,0,0}}' ${infile} | sed 1i"#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT" > ${filepath}/${prefix}.${i}
sed 's#INS_VCF#'${filepath}/${prefix}.${i}'#g' ${scriptpath}/run.vep.sh > ${filepath}/run.vep.${i}.sh
done < chromosome

rm chromosome
