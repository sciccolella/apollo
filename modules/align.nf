process clustalw {
    conda "bioconda::clustalw"

    input:
    path multifasta

    output:
    path "*.aln"

    script:
    """
    clustalw -align -type=DNA -infile=$multifasta -outfile=${multifasta.baseName}.aln
    """
}

process mafft {
    conda "bioconda::mafft"

    input:
    path multifasta

    output:
    path "*.msa"

    script:
    """
    mafft --auto --inputorder $multifasta > ${multifasta.baseName}.msa
    """
}