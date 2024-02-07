include { efetch_FromList_FASTA } from './modules/ncbi-nuc.nf'
include { buildPhylogeny } from './modules/phylo.nf'
include { publish } from './modules/helpers.nf'

workflow paper {
    Channel
        .fromPath(params.nucList)
        | efetch_FromList_FASTA
        | set { multifasta }

    phylo = buildPhylogeny(multifasta)
    phylo.trees
        .join(phylo.figs)
        | set {wfout}
    publish("paper", wfout)
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
    publish("geneton", wfout)
}


workflow {
    paper()
    geneton()
}