#!/usr/bin/perl
use warnings;
use strict;

use vcfParse;
use FindBin;

my $vcf_file = $FindBin::Bin . "/" . '../data/test_in.vcf';

my ( $data, $info_fields, $calls, $headers ) = vcfParse::parse($vcf_file);

printf "%-10s %-10s %-10s %-s\n" , "Var", "Chrom", "Genotype", "Allele frequency";

for ( sort { @{ $data->{$a}}[0] cmp @{ $data->{$b}}[0] or
		 @{ $data->{$a}}[1] <=> @{ $data->{$b}}[1]
	 }  keys %{ $data } ){
	 my ( $chrom, $pos, $id, $ref, $alt, $quality_score, $filt, $info_block, $format_block, $tumour_info_block, $normal_info_block, $samples ) = @{ $data->{$_} };

	 my (@format) 		  = @{ $info_fields->{$_}[0] }; # The format field from VCF
	 my (%format_long)  = @{ $info_fields->{$_}[1] }; # The description of the FORMAT field (corresponding to ##FORMAT=<ID=[field] in header)
	 my (%info_long)    = @{ $info_fields->{$_}[2] }; # The description of the INFO field (corresponding to ##INFO=<ID=[field] in header)
	 my (@tumour_parts) = @{ $info_fields->{$_}[3] }; # The tumour values (for each FORMAT feild)
	 my (@normal_parts) = @{ $info_fields->{$_}[4] }; # The normal values (for each FORMAT feild)
	 my (%information)  = @{ $info_fields->{$_}[5] }; # The format field from VCF
	 my (%sample_info)  = @{ $info_fields->{$_}[6] }; # Per-sample info lookup (e.g. $sample_info{$_}{'[sample_name]'}{'[FORMAT_field]'})

	 printf "%-10s %-10s %-10s %-s\n", $_, $chrom, $sample_info{$_}{'TUMOR'}{'GT'}, $sample_info{$_}{'TUMOR'}{'AF'};

 }
