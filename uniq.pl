#!/usr/bin/env perl

#Alessio Dini
#Restituisce in output elementi singoli

if(@ARGV != 1)
{
    print "Sintassi: $0 <file>\n";
    exit -1;
}

$tmp = $ARGV[0];

open(FILE, "<$tmp") || die "Non posso aprire il file $tmp\n";
while (<FILE>) {
        chomp;
        $riga = $_;
        push(@list,$riga);
}
close(FILE);

my %hash;
my @uniq = grep !$hash{$_}++, @list;

for(@uniq) {
        $var = $_;
        print "$var\n";
}
