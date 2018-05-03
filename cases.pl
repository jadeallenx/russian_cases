use 5.014;


use Text::CSV_XS qw(csv);
use Data::Printer;

my $nouns = csv( in => "nouns_utf8.csv", encoding => "UTF-8", key => 'nom' );
my $pronouns = csv( in => "pronouns_utf8.csv", encoding => "UTF-8", key => 'masc_nom' );
my $adjectives = csv( in => "adjectives_utf8.csv", encoding => "UTF-8", key => 'masc_nom' );
my $stems = csv( in => "sentence_stems_utf8.csv", encoding => "UTF-8", key => 'case' );

p $stems;


