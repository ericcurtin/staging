#!/usr/bin/perl

my $d = $ARGV[0]; # document file to pass in, every line represents a document
my $q = $ARGV[1]; # query file to pass in, every word is a term in the query

my @word_in_each_doc; # each member holds the word count of each document
my @docs; # each member holds a document (line in document file)
my $i = 0; # keeps count of line when processding file
open my $f, $d or die "Could not open $d: $!"; # open document file
while (my $line = <$f>) { # for each line in document file
  $line = lc($line); # convert to lowercase
  push(@docs, $line); # add line to doc array
  for $word (split('\s+', $line)) { # for each word in line
    ++$list{$word}; # incremement total count frequency of this word
    ++$word_in_each_doc[$i]; # incremement total word count of document
  }

  ++$i; # increment for each line
}

close($f); # close document file
open $f, $q or die "Could not open $q: $!"; # open query file
while (my $line = <$f>)  { # for each line in query file
  for $word (split('\s+', $line)) { # for each word in line
    $query_term{$word} = 1; # set to one, just to store existance
  }
}

my @total_tf_idf_per_doc= (0, 0, 0);
close($f); # close query file
# print top line
printf("%-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s %-8s\n", "word", "count",
       "TF 1", "TF 2", "TF 3", "IDF", "TF-IDF 1", "TF-IDF 2", "TF-IDF 3");
for $k (keys %query_term) { # iterate through each query term
  # array to track count frequency of word per document
  my @docs_occurances_of_this_word = (0, 0, 0);
  my $i = 0; # index of word
  for $doc (@docs) { # for every document
    for $word (split('\s+', $doc)) { # for each word in document
      if ($word eq $k) { # if this word is equal to key
        # increment the frequency of this word
        ++$docs_occurances_of_this_word[$i];
      }
    }

    ++$i; # increment the index
  }

  # calculate tf values
  my @tf = ($docs_occurances_of_this_word[0] / $word_in_each_doc[0],
            $docs_occurances_of_this_word[1] / $word_in_each_doc[1],
            $docs_occurances_of_this_word[2] / $word_in_each_doc[2]);

  # calculate idf value
  my $idf = $list{$k} ? log(3 / $list{$k}) : 0;
 
  # array of tf-idf per document and per term
  my @tf_idf_idf_per_doc_per_term = ($tf[0] * $idf, $tf[1] * $idf, $tf[2] * $idf);
  # print results for this word
  printf("%-8s %-8d %-8f %-8f %-8f %-8f %-8f %-8f %-8f\n", $k, $list{$k},
         $tf[0], $tf[1], $tf[2], $idf, $tf_idf_idf_per_doc_per_term[0],
         $tf_idf_idf_per_doc_per_term[1], $tf_idf_idf_per_doc_per_term[2]);
  $total_tf_idf_per_doc[0] += $tf_idf_idf_per_doc_per_term[0];
  $total_tf_idf_per_doc[1] += $tf_idf_idf_per_doc_per_term[1];
  $total_tf_idf_per_doc[2] += $tf_idf_idf_per_doc_per_term[2];
}

# print totals
printf("%-53s %-8f %-8f %-8f\n", "TF-IDF totals:", $total_tf_idf_per_doc[0],
       $total_tf_idf_per_doc[1], $total_tf_idf_per_doc[2]);

