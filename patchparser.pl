#!/usr/bin/perl

#
# Alessio Dini , 14/12/2009
# This tool does parsing patches
# It must be saved as patchparser.pl
# When option -g is used , this tool requires a showrev -p output file called <globalzone>.patchparser.log
#
# Example: For compare patches between system1 , system2 and system3 you have to do:
# 1) Run showrev -p on system2 and system3 global zone , and redirect output on system2.patchparser.log and system3.patchparser.log files
# 2) Copy files to system1 , on the same directory of this tool
# 3) Run patchparser.pl with -g option
#
# It's more easy to put patch files on global filesystem.
#

sub info()
{
        print "\nSyntax: $0 { -a | -g | -n | -b } \n";
        print "-a : compare patches between global zone and all running native local zone \n";
        print "-g : compare patches between two or more global zone \n";
        print "-n : compare patches between native running zones only \n";
        print "-b8 : compare patches between Solaris 8 branded running zones only \n";
        print "-b9 : compare patches between Solaris 9 branded running zones only \n\n";
        exit -1;
}

sub clear ()
{
        @totals = <*patchparser*>;
        for(@totals)
        {
                chomp;
                next if $_ =~ /^patchparser.pl$/;
                unlink($_);
        }
}


if(@ARGV != 1)
{
        &info();
}

sub work()
{
        $name = $_[0];
        for($i=0;$i<$name;$i++)
        {
               if ($i == 0)
               {
                        for($j=$i+1;$j<$name;$j++)
                        {
                               &compare($zonename[$i], $zonename[$j]);
                        }
               }
               elsif ($i == $name-1)
               {
                        for($j=0;$j<$i;$j++)
                        {
                               &compare($zonename[$i], $zonename[$j]);
                        }
               }
               else
               {
                        for($j=0;$j<$name;$j++)
                        {
                                next if "$zonename[$i]" eq "$zonename[$j]";
                                &compare($zonename[$i], $zonename[$j]);
                        }
              }
        }
}


sub compare()
{
        $su = $_[0];
        $sd = $_[1];
        next if $su =~ /^patchparser\.pl$/;
        next if $sd =~ /^patchparser\.pl$/;
        open (UNO,"<$su.patchparser.log") || die "error on opening file $su.patchparser.log\n";
        while(<UNO>)
        {
                chomp;
                $fileuno = $_;
                if ( $fileuno =~ /^Patch\:\s(\w+[\-]\w+)/ )
                {
                        $pu = $1;
                        push(@uno,$pu);
                }
        }
        close(UNO);

        open (DUE,"<$sd.patchparser.log") || die "error on opening file $sd.patchparser.log\n";
        while(<DUE>)
        {
                chomp;
                $filedue = $_;
                if ( $filedue =~ /^Patch\:\s(\w+[\-]\w+)/ ) {
                        $pd = $1;
                        push(@due,$pd);
                }
        }
        close(DUE);

        foreach my $a (@uno)
        {
                $esito = 0;
                foreach my $b(@due)
                {
                        if($a eq $b)
                        {
                                $esito = 1;
                        }
                }
                          if($esito != 1)
                          {
                                print "Missing patch $a on zone $sd\n";
                          }
        }
        @uno = ();
        @due = ();
}


if(@ARGV != 1)
{
        &info();
}
$tmp = $ARGV[0];

#
#check
#

$version = qx(uname -r);
$version =~ s/\s//g;

if ( $version ne "5.10" )
{
        print "\nThis script is for Solaris 10 only!!\n";
        exit -1;
}

die "\nYou must be root for run this tool\n" unless $< eq 0;

$global = qx(/usr/bin/zonename);
$global =~ s/\s//g;

if($global ne "global")
{
        print "This tool must be launched on global zone only\n";
        exit -1;
}


#
# option -n
#

if ($tmp eq "-n")
{
        @zonename = qx(zoneadm list -cv | grep running | grep native | grep -v global | awk '{ print \$2 }');
        for (@zonename)
        {
                chomp;
                $name = $_;
                qx(zlogin -S $name showrev -p > $name.patchparser.log);
        }
        $name = @zonename;
        &work($name);
        &clear();
}


#
# option -a
#

elsif ($tmp eq "-a")
{
        @zonename = qx(zoneadm list -cv | grep running | grep native | grep -v global | awk '{ print \$2 }');
        qx(showrev -p > $global.patchparser.log);
        for (@zonename)
        {
                chomp;
                $name = $_;
                qx(zlogin -S $name showrev -p > $name.patchparser.log);
        }
        unshift(@zonename,$global);
        $name = @zonename;
        &work($name);
        &clear();
}



#
# option -g
#

elsif ($tmp eq "-g")
{
        @files = <*patchparser*>;
        for(@files)
        {
                chomp;
                $_ =~ s/\.patchparser\.log//g;
                push(@zonename,$_);
        }
        $host = qx(hostname);
        $host =~ s/\s//g;
        qx(showrev -p > $host.patchparser.log);
        unshift(@zonename,$host);
        $name = @zonename;
        &work($name);
        &clear();

}


#
# option -b8
#


elsif ($tmp eq "-b8")
{
        @zonename = qx(zoneadm list -cv | grep running | grep solaris8 | awk '{ print \$2 }');
        for(@zonename)
        {
                chomp;
                $name = $_;
                qx(zlogin -S $name showrev -p > $name.patchparser.log);
        }
        $name = @zonename;
        &work($name);
        &clear();
}



#
# option -b9
#


elsif ($tmp eq "-b9")
{
        @zonename = qx(zoneadm list -cv | grep running | grep solaris9 | awk '{ print \$2 }');
        for(@zonename)
        {
                chomp;
                $name = $_;
                qx(zlogin -S $name showrev -p > $name.patchparser.log);
        }
        $name = @zonename;
        &work($name);
        &clear();
}

else
{
        &info();
}
