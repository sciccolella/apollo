process publishWithVersion {
    publishDir "$params.outdir/$outver", pattern: '*.msa', saveAs: { t -> "${meta.aligner}.msa" } , mode: 'copy', overwrite: true
    publishDir "$params.outdir/$outver", pattern: '*.aln', saveAs: { t -> "${meta.aligner}.aln" } , mode: 'copy', overwrite: true
    publishDir "$params.outdir/$outver", pattern: '*.treefile', saveAs: { t -> "${meta.aligner}.${meta.tree}.nh" } , mode: 'copy', overwrite: true
    publishDir "$params.outdir/$outver", pattern: '*.png', saveAs: { t -> "${meta.aligner}.${meta.tree}.png" } , mode: 'copy', overwrite: true

    input:
    val outver
    tuple val(meta), path(msa), path(tree), path(fig)

    output:
    tuple val(meta), path(msa), path(tree), path(fig)

    script: " "
}

process publish {
    publishDir "$params.outdir/", pattern: '*.msa', saveAs: { t -> "${meta.aligner}.msa" } , mode: 'copy', overwrite: true
    publishDir "$params.outdir/", pattern: '*.aln', saveAs: { t -> "${meta.aligner}.aln" } , mode: 'copy', overwrite: true
    publishDir "$params.outdir/", pattern: '*.treefile', saveAs: { t -> "${meta.aligner}.${meta.tree}.nh" } , mode: 'copy', overwrite: true
    publishDir "$params.outdir/", pattern: '*.png', saveAs: { t -> "${meta.aligner}.${meta.tree}.png" } , mode: 'copy', overwrite: true

    input:
    tuple val(meta), path(msa), path(tree), path(fig)

    output:
    tuple val(meta), path(msa), path(tree), path(fig)

    script: " "
}