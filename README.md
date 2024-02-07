# Apollo phylogenetic analysis pipeline

Prerequisites:
- [Nextflow](https://www.nextflow.io/)
- [Miniforge](https://github.com/conda-forge/miniforge) recommended for using `mamba` instead of `conda`; alternatively any `conda` installation

### Run the pipeline
```bash
nextflow run apollo.nf -config omoto.config [-resume] [-qs N]
nextflow run apollo.nf -config todisco.config [-resume] [-qs N]
```