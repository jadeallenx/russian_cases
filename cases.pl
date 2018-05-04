use 5.014;

use Text::CSV qw(csv);
use Data::Printer;

my $nouns = csv( in => "nouns_utf8.csv", encoding => "UTF-8", key => 'nom' );
my $pronouns = csv( in => "pronouns_utf8.csv", encoding => "UTF-8", key => 'masc_nom' );
my $adjectives = csv( in => "adjectives_utf8.csv", encoding => "UTF-8", key => 'masc_nom' );
my $stems = csv( in => "sentence_stems_utf8.csv", encoding => "UTF-8", key => 'case' );

sub choose_hash_key {
     my $h = shift;
    return $h->{(keys %{ $h })[rand keys %{ $h }]};
}

sub choose_stem {
    return choose_hash_key($stems);
}

sub choose_noun {
    return choose_hash_key($nouns);
}

sub choose_adjective {
    return choose_hash_key($adjectives);
}

sub choose_pronoun {
    return choose_hash_key($pronouns);
}

sub choose_plural {
    return "plural" if ( rand 1 > .5 );
    return "singular";
}

sub make_phrase {
    my $case = shift;
    my $plural = choose_plural();
    my $n = choose_noun();
    my $a = choose_adjective();
    my $p = choose_pronoun();
    my $nstr = get_noun_string($n, $case, $plural);
    my $ca = select_correct($a, $n->{gender},
                                $n->{animate},
                                $case, $plural);
    my $cp = select_correct($p, $n->{gender},
                                $n->{animate},
                                $case, $plural);
    my $r = join " ", ($cp, $ca, $nstr);
    my $e = join " ", (fix_pronoun($p->{eng}, $plural), $a->{eng},
                           $plural eq "plural" ? $n->{enp} : $n->{eng});

    return $r . " (" . $e . ")";
}

sub fix_pronoun {
    my ($p, $plural) = @_;
    if ( $p =~ /\|/ ) {
        my @l = split /\|/, $p;
        return $l[1] if $plural eq "plural";
        return $l[0];
    }
    return $p;
}

sub get_noun_string {
    my ($h, $case, $plural) = @_;
    if ( $plural eq "plural" ) {
        return $h->{nmp} if $case eq "nom";
        return $h->{acp} if $case eq "acc";
        return $h->{gnp} if $case eq "gen";
        return $h->{dtp} if $case eq "dat";
        return $h->{itp} if $case eq "inst";
        return $h->{prp} if $case eq "prep";
    }
    else {
        return $h->{$case};
    }
}

sub select_correct {
    my $h = shift;
    my $k = select_correct_key(@_);
    return $h->{$k};
}

sub select_correct_key {
    my ($gender, $animate, $case, $plural) = @_;

    if ( $plural eq "plural" ) {
        if ( $case eq "acc" ) {
            return "pl_gen" if $animate eq "a"; #animate nouns get genitive endings
            return "pl_nom"; # inanimate nouns get nominative endings
        }

        return "pl_".$case;
    }
    else {
        if ( $gender eq "m" ) {
            if ( $case eq "acc" ) {
                return "masc_gen" if $animate eq "a";
                return "masc_nom";
            }
             return "masc_$case";
        }
        elsif ( $gender eq "f" ) {
             return "fem_nom" if $case eq "nom";
             return "fem_acc" if $case eq "acc";
             return "fem_oth";
        }
        elsif ( $gender eq "n" ) {
             return "neu_nom" if $case eq "nom";
             return "neu_nom" if $case eq "acc";
             return "masc_$case";
        }
        else {
             return "unknown";
        }
    }
}

for ( 1..10 ) {
    my $s = choose_stem();
    my $phrase = make_phrase($s->{case});
    say $s->{rus} . " " . $phrase . " : " . $s->{case};
}
