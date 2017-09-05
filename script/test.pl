#!/usr/bin/perl
use warnings;
use strict;

use vcfParse;
use FindBin;

my $vcf_file = $FindBin::Bin . "/" . '../data/test_in.vcf';

my ( $data, $info_fields, $filtered_vars ) = vcfParse::parse($vcf_file);

printf "%-10s %-10s %-s\n" , "Var", "Genotype", "Allele frequency";

for ( sort { @{ $data->{$a}}[0] cmp @{ $data->{$b}}[0] or
		 @{ $data->{$a}}[1] <=> @{ $data->{$b}}[1]
	 }  keys %{ $data } ){
	 my ( $chrom, $pos, $id, $ref, $alt, $quality_score, $filt, $info_block, $format_block, $tumour_info_block, $normal_info_block, $filters, $samples ) = @{ $data->{$_} };
	 my (%sample_info)  = @{ $info_fields->{$_}->[6] };

	 printf "%-10s %-10s %-s\n", $_, $sample_info{$_}{'TUMOR'}{'GT'}, $sample_info{$_}{'TUMOR'}{'AF'};
 }
