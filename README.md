# vcfParse

A perl module to parse vcf files for easy filtering

## Installation

Install from github:

```
git clone https://github.com/nriddiford/vcfParse.git
cd vcfParse
```

Install module:

```
perl Makefile.PL
make
make test
make install
```

## Call vcfParse from script:

```{perl}
use vcfParse;

my $vcf_file = 'in_file.vcf';

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

```
