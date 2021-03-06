% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rcrux_blast.R
\name{rcrux_blast}
\alias{rcrux_blast}
\title{A wrapper function for blast_datatable that reads a data.frame from a path}
\usage{
rcrux_blast(
  seeds_path,
  save_dir,
  db_dir,
  accession_taxa_path,
  expand_vectors = TRUE,
  ...
)
}
\arguments{
\item{seeds_path}{a path to a csv from get_blast_seeds}

\item{save_dir}{a directory, passed to blast_datatable for it to save to}

\item{db_dir}{a directory containing a blast-formatted database}

\item{accession_taxa_path}{a path to the accessionTaxa sql created by
taxonomizr}

\item{expand_vectors}{logical, determines whether to expand too_many_Ns
and not_in db into real tables}
}
\description{
Reads a data.frame from path,
then passes it to blast_datatable
then writes the output.
}
