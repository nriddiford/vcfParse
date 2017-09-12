package vcfParse;

use 5.006;
use strict;
use warnings;

=head1 NAME

vcfParse - The great new vcfParse!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS
 use vcfParse;

 my $vcf_file = 'in_file.vcf';
 my ( $data, $info_fields, $filtered_vars ) = vcfParse::parse($vcf_file);

 for ( sort { @{ $data->{$a}}[0] cmp @{ $data->{$b}}[0] or
      @{ $data->{$a}}[1] <=> @{ $data->{$b}}[1]
    }  keys %{ $data } ){
    my ( $chrom, $pos, $id, $ref, $alt, $quality_score, $filt, $info_block, $format_block, $tumour_info_block, $normal_info_block, $filters, $samples ) = @{ $data->{$_} };
    my (%sample_info)  = @{ $info->{$_}->[6] };

    if ($sample_info{$_}{'TUMOR'}{'AF'}){
      print "Allele frequency = "$sample_info{$_}{'TUMOR'}{'AF'}\n";
    }
    ...
  }


=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=cut

require Exporter;

  our @ISA = qw(Exporter);

  our %EXPORT_TAGS = (
          'all' => [ qw(
                          parse
                  ) ]
  );

  our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

  our @EXPORT = qw(
                          parse
  );

=head1 SUBROUTINES/METHODS

=head2 parse

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
       $variants{$.} = $_;

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
      $variants{$.} = $_;
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

    my @filter_reasons;
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

    $snvs{$id} = [ @fields[0..10], \@filter_reasons, \@samples ];

    $info{$id} = [ [@format], [%format_long], [%info_long], [@tumour_parts], [@normal_parts], [%information], [%sample_info] ];

    if ( scalar @filter_reasons == 0 ){
      $variants{$.} = $_;
    }

  }

  return (\%snvs, \%info, \%variants);
}


=head1 AUTHOR

Nick Riddiford, C<< <nick.riddiford at curie.fr> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-vcfparse at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=vcfParse>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc vcfParse


You can also look for information at:

=over 1

=item * Github

L<https://github.com/nriddiford/vcfParse>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2017 Nick Riddiford.

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


=cut

1; # End of vcfParse
