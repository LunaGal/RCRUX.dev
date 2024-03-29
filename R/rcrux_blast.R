#' Wrapper function for blast_datatable that reads a data.frame from a path
#'
#' @description
#' rcrux_ blast uses [RCRUX.dev::blast_datatable()] to search against a blast
#' formatted database. It creates a directory at `working_dir` if one does not
#' already exist and generates `rcrux_blast_output` and `.rcrux_blast_save`
#' inside that directory. It passes `<working_dir>/.rcrux_blast_save` to
#' [RCRUX.dev::blast_datatable()] as the save directory and generates files in
#' `rcrux_blast_output` recording the results of the blast.
#'
#' @details
#' # Saving data
#' The [RCRUX.dev::blast_datatable()] call saves intermediate results and
#' metadata about the search as local files in the save directory generated by
#' rcrux_blast. This allows the function to resume a partially
#' completed blast, mitigating the consequences of encountering an
#' error or experiencing other interruptions. To resume a partially completed
#' blast, supply the same seeds and working directory. See the documentation
#' of [RCRUX.dev::blast_datatable()] for more information.
#'
#' @param seeds_path a path to a csv from get_blast_seeds
#' @param db_dir a directory containing a blast-formatted database
#' @param accession_taxa_path a path to the accessionTaxa sql created by
#'        taxonomizr
#' @param working_dir a directory in which to save partial and complete output
#' @param metabarcode a prefix for the fasta
#' @param expand_vectors logical, determines whether to expand too_many_Ns
#'        and not_in db into real tables and write them in the output directory
#' @param warnings value to set the "warn" option to during the function call.
#'        On exit it returns to the previous value. Setting this argument to
#'        NULL will not change the option.
#' @param ... additional arguments passed to [RCRUX.dev::blast_datatable()]
#' @return NULL
#' @export
rcrux_blast <- function(seeds_path, db_dir, accession_taxa_path, working_dir,
                        metabarcode, expand_vectors = TRUE, warnings = 0, ...) {
    # So that run_blastdbcmd doesn't overwhelm the user with errors
    # Possibly we should discard the warnings from blastdb as it's entirely
    # expected to encounter so values that are not in the database.
    if (!is.null(warnings)) {
        old_warnings <- getOption("warn")
        on.exit(options(warn = old_warnings))
        options(warn = warnings)
    }

    output_dir <- paste(working_dir, "rcrux_blast_output", sep = "/")
    save_dir <- paste(working_dir, "rcrux_blast_save", sep = "/")
    dir.create(working_dir)
    dir.create(save_dir)
    dir.create(output_dir)
    blast_seeds <- read.csv(seeds_path)
    output_table <- blast_datatable(blast_seeds, save_dir, db_dir,
                    accession_taxa_path, ...)

    # Write output_table to dir/rcrux_blast_output/summary.csv
    summary_csv_path <- paste(output_dir, "summary.csv", sep = "/")
    write.csv(output_table, file = summary_csv_path, row.names = FALSE)

    # Write a fasta
    get_fasta_no_hyp(output_table, output_dir, metabarcode)
    
    # filter step
    taxa_table <- output_table %>%
        dplyr::filter_at(dplyr::vars(genus), dplyr::all_vars(!is.na(.))) %>%
        dplyr::filter_at(dplyr::vars(genus,family), dplyr::all_vars(!is.na(.)))

    # Taxonomy file format (tidyr and dplyr)
    taxa_table <- taxa_table %>%
        select(accession, superkingdom, phylum, class, order, family, genus, species) %>%
        unite(taxonomic_path, superkingdom:species, sep = ";", remove = TRUE, na.rm = FALSE)
    
    # Write the thing
    taxa_table_path <- paste0(output_dir, "/", metabarcode, "taxonomy.tab")
    write.table(taxa_table, file = taxa_table_path, row.names = FALSE)

    # Read condensed vectors and expand them
    if (expand_vectors) {
        too_many_ns_path <- paste(save_dir, "too_many_ns.txt", sep = "/")
        too_many_ns_indices <- as.numeric(readLines(too_many_ns_path))
        too_many_ns <- blast_seeds[too_many_ns_indices, ]
        too_many_ns_csv_path <- paste(output_dir, "too_many_ns.csv", sep = "/")
        write.csv(too_many_ns, file = too_many_ns_csv_path, row.names = FALSE)

        blastdbcmd_failed_path <- paste(save_dir, "blastdbcmd_failed.txt", sep = "/")
        blastdbcmd_failed_indices <- as.numeric(readLines(blastdbcmd_failed_path))
        blastdbcmd_failed <- blast_seeds[blastdbcmd_failed_indices, ]
        blastdbcmd_failed_csv_path <- paste(output_dir, "blastdbcmd_failed.csv", sep = "/")
        write.csv(blastdbcmd_failed, file = blastdbcmd_failed_csv_path, row.names = FALSE)
    }
    return(NULL)
}

get_fasta_no_hyp <- function(dupt, file_out_dir, Metabarcode_name) {
    dupt_no_hiyp <- dupt %>% mutate(sequence = gsub("-", "", sequence))
    fasta <- character(nrow(dupt_no_hiyp) * 2)
    fasta[c(TRUE, FALSE)] <- paste0(">", dupt_no_hiyp$accession)
    fasta[c(FALSE, TRUE)] <- dupt_no_hiyp$sequence
    writeLines(fasta, paste0(file_out_dir, "/", Metabarcode_name, "_.fasta"))
}
