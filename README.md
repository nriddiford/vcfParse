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

    my (@headers)      = @{ $info_fields->{$_}[0] }; # The header fileds from VCF (starting with '#')
    my (@format)       = @{ $info_fields->{$_}[1] }; # The format field from VCF
    my (%format_long)  = @{ $info_fields->{$_}[2] }; # The description of the FORMAT field (corresponding to ##FORMAT=<ID=[field] in header)
    my (%info_long)    = @{ $info_fields->{$_}[3] }; # The description of the INFO field (corresponding to ##INFO=<ID=[field] in header)
    my (@tumour_parts) = @{ $info_fields->{$_}[4] }; # The tumour values (for each FORMAT feild)
    my (@normal_parts) = @{ $info_fields->{$_}[5] }; # The normal values (for each FORMAT feild)
    my (%information)  = @{ $info_fields->{$_}[6] }; # The format field from VCF
    my (%sample_info)  = @{ $info_fields->{$_}[7] }; # Per-sample info lookup (e.g. $sample_info{$_}{'[sample_name]'}{'[FORMAT_field]'})

    if ( $sample_info{$_}{'TUMOR'}{'AF'} ){
        print "Allele frequency = "$sample_info{$_}{'TUMOR'}{'AF'}\n";
    }
    # Do more things
}
```
