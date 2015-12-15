#!/usr/bin/perl
for ($i = 0; $i <= (4500); $i++) {
  system("fetchmail -kB40");
  do {
    sleep 10;
    chomp($num = `/usr/bin/ps -ef | /usr/bin/grep rails | /usr/bin/wc -l`);
    print "$num ..";
  } while ($num > 10);
  print "\n";
}
