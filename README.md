# vcfParse

A perl module to parse vcf files for easy filtering

## Installation

Install from github:

```
git clone https://github.com/nriddiford/vcfParse.git
cd mutationProfiles
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


SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc vcfParse


LICENSE AND COPYRIGHT

Copyright (C) 2017 Nick Riddiford

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
