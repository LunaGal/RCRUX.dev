% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_blast_seeds.R
\name{get_blast_seeds}
\alias{get_blast_seeds}
\title{Query primer_blast and generate a .csv to use for rcrux_blast}
\usage{
get_blast_seeds(
  forward_primer,
  reverse_primer,
  file_out_dir,
  Metabarcode_name,
  accessionTaxa,
  organism,
  mismatch = 3,
  minimum_length = 5,
  maximum_length = 500,
  primer_specificity_database = "nt",
  HITSIZE = 1e+05,
  NUM_TARGETS_WITH_PRIMERS = 1e+05,
  ...,
  return_table = TRUE
)
}
\arguments{
\item{forward_primer}{passed to primer_search, which turns it into a list of
each primer it could be based on its degenerate primers, then passes
each one in turn to NCBI}

\item{reverse_primer}{passed to primer_search, which turns it into a list of
each primer it could be based on its degenerate primers, then passes
each one in turn to NCBI}

\item{file_out_dir}{the parent directory to place the data in.}

\item{Metabarcode_name}{used to name the subdirectory and the files. If a
directory named Metabarcode_name does not exist in file_out_dir, a
new directory will be created. get_blast_seeds appends
Metabarcode_name to the beginning of each of the two files it
generates.}

\item{accessionTaxa}{the path to sql created by taxonomizr}

\item{organism}{a vector of character vectors. Each character vector is
passed in turn to primer_search, which passes them to NCBI.
get_blast_seeds aggregates all of the results into a single file.}

\item{mismatch}{the highest acceptable mismatch value. parse_primer_hits
returns a table with a mismatch column. get_blast_seeds removes each
row with a mismatch greater than the specified value.}

\item{minimum_length}{parse_primer_hits returns a table with a product_length
column. get_blast_seeds removes each row that has a value less than
minimum_length in the product_length column.}

\item{maximum_length}{parse_primer_hits returns a table with a
product_length column. get_blast_seeds removes each row that has a
value greater than maximum_length in the product_length column}

\item{primer_specificity_database}{passed to primer_search, which passes it
to NCBI}

\item{HITSIZE}{a primer BLAST search parameter set high to maximize the
number of observations returned.}

\item{NUM_TARGETS_WITH_PRIMERS}{a primer BLAST search parameter set high to
maximize the number of observations returned.}

\item{...}{additional arguments passed to primer_search, which passes it to
NCBI}
}
\value{
a data.frame containing the same information as the .csv it generates
}
\description{
get_blast_seeds uses a modified version of \code{\link[primerTree:primer_search]{primerTree::primer_search()}} to
query NCBI's \href{https://www.ncbi.nlm.nih.gov/tools/primer-blast/}{primer BLAST}
tool, filters the results, then aggregates them into a single data.frame.
As a side effect, it creates a directory at \code{file_out_dir} if one doesn't yet
exist, then creates a subdirectory inside \code{file_out_dir} named after
\code{Metabarcode_name}. It creates two files inside that directory, one
representing the output and the other representing the output without added
taxonomy.
}
\section{Additional arguments passed to primer BLAST}{
get_blast_seeds passes many parameters to NCBI's primer blast tool. You can
match the parameters to the fields available in the GUI
\href{https://www.ncbi.nlm.nih.gov/tools/primer-blast/}{here}. First, use your
browser to view the page source. Search for the field you are interested in
by searching for the title of the field. It should be enclosed in a tag.
Inside the label tag, it says \verb{for = "<name_of_parameter>"}. Copy the string
after for = and add it to get_blast_seeds as the name of a parameter, setting
it equal to whatever you like.

As of 2022-08-16, the primer blast GUI
contains some options that are not implemented by primer_search.
primer_search doesn't include explicit documentation of allowed options, but
it will quickly report if an option isn't allowed, so trial and error will
not be very time consuming.

Example: I want to set "Exon junction span" to 10. I open the source of the
primer designing tool and look for that string. I find the following:

\if{html}{\out{<div class="sourceCode">}}\preformatted{<label class="m" for="PRIMER_ON_SPLICE_SITE">Exon junction span</label>
}\if{html}{\out{</div>}}

I copy PRIMER_ON_SPLICE_SITE and add it to get_blast_seeds:

\if{html}{\out{<div class="sourceCode">}}\preformatted{get_blast_seeds("TAGAACAGGCTCCTCTAG", "TTAGATACCCCACTATGC",
             blast_seeds_parent, "12S_V5F1", accession_taxa_path,
             organism = c("7776"), MAX_TARGET_PER_TEMPLATE = 10,
             PRIMER_ON_SPLICE_SITE = "10"
             return_table = FALSE)
}\if{html}{\out{</div>}}
}

