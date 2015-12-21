#!/usr/bin/perl
for ($i = 0; $i <= (4500); $i++) {
  system("fetchmail -kB40");
  do {
    sleep 10;
    @mailq = `/usr/bin/mailq`;
    @line = grep(/\d+ Requests./, @mailq);
    $line[0] =~ /(\d+) Requests./;
    $num = $1;
    print "$num ..";
  } while ($num > 100);
  print "\n";
}
