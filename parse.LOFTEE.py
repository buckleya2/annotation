'''
script that takes in table output from VEP/LOFTEE
converts variant coordinates to VCF format
only outputs HC variants
output columns : chr, pos, ref, alt, gene id, tx id
'''
from pyfaidx import Fasta
from sys import argv
script, input, output=argv

# load in grch37 reference fasta
grch=Fasta('/cellar/users/abuckley/ref/hs37d5.fa')

# open output file
OUT=open(output, "w")

'''
function that converts indels from "-" format to VCF format where preceding base is reported
ex: AT/- vs. CAT/C;  -/TT vs. A/ATT
'''
def convert_indels(CHR,POS,REF,ALT):
	newcoord={}
# for insertions, position remains the same
	if REF == "-":
		startloc=int(POS)-1
		startbase=grch[CHR][startloc].seq
		newcoord.update({'chr' : CHR, 'pos' : POS, 'ref' : startbase , 'alt' : startbase + ALT})

# for deletions, start position is one base prior to that reported
	elif ALT == "-":
		startloc=int(POS)-2
		startbase=grch[CHR][startloc].seq
		newcoord.update({'chr' : CHR, 'pos' : int(POS)-1, 'ref' : startbase + REF , 'alt' : startbase })    
	return(newcoord)


with open(input) as F:
	for line in F:
# skip header lines
		if "#" in line:
			continue
# parse out correct chr, pos, ref, alt from file			
		parsed=line.strip().split("\t")
		chr=parsed[0].split("_")[0]
		ref=parsed[0].split("_")[2].split("/")[0]
		pos=parsed[1].split(":")[1].split("-")[0]
		alt=parsed[2]
		gene=parsed[3]
		tx=parsed[4]
# turn LOFTEE annotations into a dict
		info=parsed[13].split(";")
		info_dict=dict(map(lambda x: x.split("="),info))
# only parse output for variants predicted to be HC LOF
		if 'LoF' in info_dict and info_dict['LoF'] == "HC" :
# if site is an indel, parse LOFTEE indel format 			
			if ref == "-" or alt == "-" :
				out=convert_indels(chr, pos, ref, alt)
				nchr=out['chr']
				npos=out['pos']
				nref=out['ref']
				nalt=out['alt']
				format="%s\t%s\t%s\t%s\t%s\t%s\n" % (nchr, npos, nref, nalt, gene, tx)
				OUT.write(format)
			else :
				format="%s\t%s\t%s\t%s\t%s\t%s\n" % (chr, pos, ref, alt, gene, tx)
				OUT.write(format)
		else :
			continue
