include { efetch_FromList_FASTA } from './modules/ncbi-nuc.nf'
include { buildPhylogeny } from './modules/phylo.nf'
include { publish; publishWithVersion } from './modules/helpers.nf'
include { rotate } from './modules/align.nf'

params.from = "fasta"

workflow paper {
    Channel
        .fromPath(params.nucList)
        | efetch_FromList_FASTA
        | set { multifasta }

    phylo = buildPhylogeny(multifasta)
    phylo.trees
        .join(phylo.figs)
        | set {wfout}
    publishWithVersion("paper", wfout)
}

workflow geneton {
    Channel
        .fromPath(params.nucList)
        | efetch_FromList_FASTA
        | set { multifasta }

    multifasta
        .concat( Channel.fromPath(params.genetonFA) )
        .collectFile(name: 'samples.txt')
        .set { multifasta }

    phylo = buildPhylogeny(multifasta)
    phylo.trees
        .join(phylo.figs)
        | set {wfout}
    publishWithVersion("geneton", wfout)
}

workflow fromSingleFA {
    if (params.normalizedFA != "") {
        multifasta =  Channel
            .fromPath(params.mtFA)
    } else {
        queries = Channel.fromPath("$params.queries")
            .collectFile(name: 'queries.txt')
        multifasta = rotate(Channel.fromPath(params.reference), queries)
    }

    phylo = buildPhylogeny(multifasta)
    phylo.trees
        .join(phylo.figs)
        | set {wfout}
    publish(wfout)
}

workflow {
    switch(params.from){
        case "fasta":
            fromSingleFA()
            break
        case "nuc":
            paper()
            geneton()
            break
    }
}