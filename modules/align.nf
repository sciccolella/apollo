params.mafftArgs = "--auto"
params.clustalwArgs = ""
params.clustaloArgs = "--auto"

params.rotatePath = "$baseDir/src/rotate"

process rotate {
    input:
    path ref
    path multifasta

    output:
    path "rotated.fa"

    script:
    """
    $params.rotatePath $ref $multifasta > rotated.fa
    """
}

process clustalw {
    conda "bioconda::clustalw"

    input:
    path multifasta

    output:
    path "*.aln"

    script:
    """
    clustalw -align -type=DNA -infile=$multifasta -outfile=${multifasta.baseName}.aln $params.clustalwArgs
    """
}

process clustalo {
    conda "bioconda::clustalo"
    cpus 8

    input:
    path multifasta

    output:
    path "*.aln"

    script:
    """
    clustalo --output-order=input-order -i $multifasta --threads=${task.cpus} -o ${multifasta.baseName}.aln $params.clustaloArgs
    """
}

process mafft {
    conda "bioconda::mafft"
    cpus 8

    input:
    path multifasta

    output:
    path "*.msa"

    script:
    """
    mafft $params.mafftArgs --inputorder --thread ${task.cpus} $multifasta > ${multifasta.baseName}.msa
    """
}