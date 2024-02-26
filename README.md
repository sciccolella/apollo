# Apollo phylogenetic analysis pipeline

Prerequisites:
- [Nextflow](https://www.nextflow.io/)
- [Miniforge](https://github.com/conda-forge/miniforge) recommended for using `mamba` instead of `conda`; alternatively any `conda` installation

## Run the pipeline

### Configuration
Run the pipeline from a reference and a list of `fasta` files, the configuration file is
`mt.config`, including the following information:

```groovy
params.reference = "data/Parnassius_apollo_yh0315_mitochondrion_NCBIreference.fasta"
params.queries = "data/fullmt/*.fasta"
params.normalizedFA = ""
params.outdir = "out/fullmt/"
```

If `params.normalizedFA` is not null the pipeline will execute starting from that file, 
otherwise a normalized `fasta` will be computed from `params.reference` and `params.queries`.
This step realigns all the `queries` according to the `reference`, moving the initial position
to match the one on the `reference` using the program `scr/rotate`. 
This will avoid multiple starting position for circular DNA.

### Runinng
Simply run the following command

```bash
nextflow run apollo.nf -qs 10 -resume -config mt.config [OPTIONS]
```

### Optional parameters

- `--mafftArgs`: it is possible to specify additional parameters that will be passed to `mafft` \[default `--mafftArgs="--auto"`\].
        <br>Example: `--mafftArgs="--globalpair --maxiterate 1000"` 
- `--clustalwArgs`: it is possible to specify additional parameters that will be passed to `clustalw` \[default `--clustalwArgs=""`\].
- `--clustaloArgs`: it is possible to specify additional parameters that will be passed to `clustalo` \[default `--clustaloArgs="--auto"`\].
- `--iqtreeArgs`: it is possible to specify additional parameters that will be passed to `iqtree` \[default `--iqtreeArgs=""`\].