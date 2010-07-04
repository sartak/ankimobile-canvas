#!/usr/bin/env perl
use strict;
use warnings;
use DBI;

@ARGV == 1 or die "usage: $0 PATHTODECK\n";
my $deck_path = shift;

my $dbh = DBI->connect("dbi:SQLite:dbname=$deck_path");

my $new_css = read_file('mobileCSS.css');

my $new_js  = join "\n",
              map { read_file($_) }
              'character.js',
              'webcanvas.js',
              'ankimobile.js';


add_or_replace_dbwise('mobileCSS', $new_css);
add_or_replace_dbwise('mobileJS', $new_js);

sub add_or_replace_dbwise {
    my $key = shift;
    my $new = shift;

    if (my ($old) = $dbh->selectrow_array('select value from deckVars where key=?;', {}, $key)) {
        my $value = add_or_replace_stringwise($old, $new, $key);
        $dbh->do('update deckVars set value=? where key=?', {}, $value, $key);
        print "Rewrote $key\n";
    }
    else {
        my $value = add_or_replace_stringwise('', $new, $key);
        $dbh->do('insert into deckVars (key, value) values (?, ?);', {}, $key, $value);
        print "Added $key\n";
    }
}

sub add_or_replace_stringwise {
    my $old = shift;
    my $new = shift;
    my $tag = shift;

    $old =~ s{
        \s*
        (\Q/*BEGIN_AnkiMobile-canvas_$tag*/\E)
        .*
        (\Q/*END_AnkiMobile-canvas_$tag*/\E)
        \s*
    }{\n$1\n$new\n$2\n}sx and return $old;

    return join "\n",
        $old,
        "/*BEGIN_AnkiMobile-canvas_$tag*/",
        $new,
        "/*END_AnkiMobile-canvas_$tag*/";
}

sub read_file {
    my $file = shift;
    open my $handle, '<', $file or die "Unable to open $file for reading: $!";
    local $/;
    return scalar <$handle>;
}

