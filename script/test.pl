#!/usr/bin/perl
use warnings;
use strict;

use vcfParse;

my $vcf_file = '/Users/Nick_curie/Desktop/script_test/mutationProfiles/data/A573R25_filtered.snv.vcf';

my ( $data, $info_fields, $filtered_vars ) = vcfParse::parse($vcf_file);

for ( sort { @{ $data->{$a}}[0] cmp @{ $data->{$b}}[0] or
		 @{ $data->{$a}}[1] <=> @{ $data->{$b}}[1]
	 }  keys %{ $data } ){
	 my ( $chrom, $pos, $id, $ref, $alt, $quality_score, $filt, $info_block, $format_block, $tumour_info_block, $normal_info_block, $filters, $samples ) = @{ $data->{$_} };
	 my (%sample_info)  = @{ $info_fields->{$_}->[6] };

	 if ($sample_info{$_}{'TUMOR'}{'AF'}){
		 print "Allele frequency = $sample_info{$_}{'TUMOR'}{'AF'}\n";
	 }
 }
