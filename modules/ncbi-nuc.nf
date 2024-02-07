process efetch_FromID_FASTA {
    conda "bioconda::entrez-direct"

    input:
    val nucID

    output:
    tuple val(nucID), path("${nucID}.fasta")

    script:
    """
    efetch -db nuccore -id $nucID -format fasta > ${nucID}.fasta
    """
}

process efetch_FromList_FASTA {
    conda "bioconda::entrez-direct"

    input:
    path list

    output:
    path "${list}.fasta"

    script:
    """
    efetch -db nuccore -input $list -format fasta > ${list}.fasta
    """
}

// params.list="../todisco.genbank.cleaned.list"

// workflow {
//     Channel
//         .fromPath(params.list)
//         .splitText()
//         .map { it -> it.trim() }
//         | efetch_FromID_FASTA
//         | view


//     Channel
//         .fromPath(params.list)
//         | efetch_FromList_FASTA
//         | view
// }