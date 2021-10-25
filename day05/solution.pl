use strict;
use Digest::MD5 qw(md5_hex);

my $prefix = <STDIN>;
my $i = 0;
my $password = "";

# Part2 stuff
my @positions = ("", "", "", "", "", "", "", "");
my $found = 0;

while(length $password < 8 || $found < 8) {
    my $digest = md5_hex($prefix . $i);

    if(substr($digest, 0, 5) eq "00000") {
        my $c = substr($digest, 5, 1);

        if(length $password < 8) {
            $password .= $c;
        }

        my $position = hex($c);
        if($position < 8 && $positions[$position] eq "") {
            $found++;
            $positions[$position] = substr($digest, 6, 1);
        }
    }

    $i++;
}

my $password2 = join('', @positions);

print("Part 1: ${password}\n");
print("Part 2: ${password2}\n");