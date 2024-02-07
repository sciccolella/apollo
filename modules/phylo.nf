include { clustalw; mafft } from './align.nf'

process iqtree {
    memory '16 GB'
    cpus 4

    conda "bioconda::iqtree"
    // publishDir "$params.outdir/", pattern: '*.treefile', saveAs: { t -> "${meta.aligner}.iqtree.nh" } , mode: 'copy', overwrite: true

    input:
    tuple val(meta), path(msa)

    output:
    tuple val(meta), path(msa), path("${msa}.treefile"), emit: treefile
    path("${msa}.iqtree"), emit: iqtreeFile

    script:
    """
    iqtree2 -s $msa -nt ${task.cpus}
    """
}

process draw {
    conda "biopython matplotlib"
    // publishDir "$params.outdir/", pattern: 'tree.png', saveAs: { t -> "${meta.aligner}.${meta.tree}.$t" } , mode: 'copy', overwrite: true

    input:
    tuple val(meta), path(msa), path(tree)
    each path(fasta)

    output:
    tuple val(meta), path("tree.png")

    script:
    """
    python $baseDir/scripts/drawphylo.py -t $tree -m $msa -f $fasta -o tree.png
    """
}

workflow buildPhylogeny {
    take: multifasta

    main:        
        multifasta
            | clustalw
            | map {
                it -> [[aligner:"clustalw"], it]
            }
            | set { msa_clw }
            
        multifasta
            | mafft
            | map {
                it -> [[aligner:"mafft"], it]
            }
            | set { msa_mft }

        iqtree_out = msa_clw
            .concat(msa_mft)
            | iqtree

        iqtree_out.treefile
            .map {
                it -> 
                (meta, msa, tree) = it
                meta.put("tree", "iqtree")
                [meta, msa, tree]
            }
            | set { treeout }

        drawout = draw(treeout, multifasta)

    emit:
        trees = treeout
        figs = drawout
}