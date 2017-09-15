package vcfParse;

use 5.006;
use strict;
use warnings;

require Exporter;

  our @ISA = qw(Exporter);

  our %EXPORT_TAGS = (
          'all' => [ qw(
                          parse
                  ) ]
  );

  our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

  our @EXPORT = qw( parse );

=head1 NAME

vcfParse - Easy parsing of VCF files

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

 use vcfParse;

 my $vcf_file = 'in_file.vcf';
 my ( $data, $info_fields, $filtered_vars, $heads ) = vcfParse::parse($vcf_file);

 my (@headers) = @{$heads};

 for ( sort { @{ $data->{$a}}[0] cmp @{ $data->{$b}}[0] or
      @{ $data->{$a}}[1] <=> @{ $data->{$b}}[1]
    }  keys %{ $data } ){
    my ( $chrom, $pos, $id, $ref, $alt, $quality_score, $filt, $info_block, $format_block, $tumour_info_block, $normal_info_block, $filtered_vars, $samples ) = @{ $data->{$_} };

    my (@format) 		  = @{ $info_fields->{$_}[0] }; # The format field from VCF
 	  my (%format_long)  = @{ $info_fields->{$_}[1] }; # The description of the FORMAT field (corresponding to ##FORMAT=<ID=[field] in header)
 	  my (%info_long)    = @{ $info_fields->{$_}[2] }; # The description of the INFO field (corresponding to ##INFO=<ID=[field] in header)
 	  my (@tumour_parts) = @{ $info_fields->{$_}[3] }; # The tumour values (for each FORMAT feild)
 	  my (@normal_parts) = @{ $info_fields->{$_}[4] }; # The normal values (for each FORMAT feild)
 	  my (%information)  = @{ $info_fields->{$_}[5] }; # The format field from VCF
 	  my (%sample_info)  = @{ $info_fields->{$_}[6] }; # Per-sample info lookup (e.g. $sample_info{$_}{'[sample_name]'}{'[FORMAT_field]'})

    if ( $sample_info{$_}{'TUMOR'}{'AF'} ){
        print "Allele frequency = "$sample_info{$_}{'TUMOR'}{'AF'}\n";
    }
    # Do more things
 }

=cut

=head1 SUBROUTINES/METHODS

=head2 parse()

=cut

sub parse {
  my ($file) = shift;
  open my $in, '<', $file or die $!;

  my @headers;

  my (%snvs, %info, %variants);
  my ($tumour_name, $control_name);
  my %format_long;
  my %info_long;
  my $filter_count;
  my @samples;
  my $replacement_id = 1;

  while(<$in>){
    chomp;

    if (/^#{2}/){
       push @headers, $_;
       #$variants{$.} = $_;

      if (/##FORMAT/){

        my ($format_long) = $_ =~ /\"(.*?)\"/;
        my ($available_format_info) = $_ =~ /ID=(.*?),/;
        $format_long{$available_format_info} = $format_long;
      }

      if (/##INFO/) {
        my ($info_long) = $_ =~ /\"(.*?)\"/;
        my ($available_info) = $_ =~ /ID=(.*?),/;
        $info_long{$available_info} = $info_long;
      }
      next;
    }

    if (/^#{1}/){
      push @headers, $_;
      #$variants{$.} = $_;
      my @split = split;
      push @samples, $_ foreach @split[9..$#split];

      $control_name = $samples[0];
      $tumour_name = $samples[1];
      next;
    }

    my @fields = split;

    my ($chr, $pos, $id, $ref, $alt, $quality_score, $filt, $info_block, $format_block, @sample_info) = @fields;

    if ( $id eq '.' ){
      $id = $replacement_id++;
    }

    my %sample_parts;

    push @{$sample_parts{$samples[$_]}}, split(/:/, $sample_info[$_]) for 0..$#samples;

    my @normal_parts   = split(/:/, $sample_info[0]);
    my @tumour_parts   = split(/:/, $sample_info[1]);

    my @format        = split(/:/, $format_block);
    my @info_parts    = split(/;/, $info_block);

    my %sample_info;

    for my $sample (@samples){
      for my $info (0..$#format){
        $sample_info{$id}{$sample}{$format[$info]} = $sample_parts{$sample}[$info];
      }
    }

    my %information;

    foreach(@info_parts){

      my ($info_key, $info_value);

      if (/=/){
        ($info_key, $info_value) = $_ =~ /(.*)=(.*)/;
      }

      else {
        ($info_key) = $_ =~ /(.*)/;
        $info_value = "TRUE";
      }
      $information{$id}{$info_key} = $info_value;
    }

    $snvs{$id} = [ @fields[0..10] ];

    $info{$id} = [ [@format], [%format_long], [%info_long], [@tumour_parts], [@normal_parts], [%information], [%sample_info] ];

    $variants{$id} = $_;

  }
  return (\%snvs, \%info, \%variants, \@headers);
}


=head1 AUTHOR

Nick Riddiford, C<nick.riddiford@curie.fr>

=head1 BUGS

Please report any bugs or feature requests to C<nick.riddiford@curie.fr>,
or via the GitHub issues page L<https://github.com/nriddiford/vcfParse/issues>

=head1 SUPPORT

=over 1

=item Github: L<https://github.com/nriddiford/vcfParse/blob/master/README.md>

=item perdoc: 'perldoc vcfParse'

=back

=head1 LICENSE AND COPYRIGHT

MIT License

Copyright (c) 2017 Nick Riddiford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut

1;
