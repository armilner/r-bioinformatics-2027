# r-bioinformatics-2027

[![Build and Push Container](https://github.com/armilner/r-bioinformatics-2027/actions/workflows/build.yml/badge.svg)](https://github.com/armilner/r-bioinformatics-2027/actions/workflows/build.yml)
[![R](https://img.shields.io/badge/R-4.6.1-blue)](https://www.r-project.org/)
[![Bioconductor](https://img.shields.io/badge/Bioconductor-3.23-green)](https://bioconductor.org/)
[![Seurat](https://img.shields.io/badge/Seurat-v5-blueviolet)](https://satijalab.org/seurat/)
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)
[![Apptainer](https://img.shields.io/badge/Apptainer-compatible-orange)](https://apptainer.org/)

One R container for bioinformatics: single-cell, spatial, bulk RNA-seq, methylation, ATAC-seq and pathway analysis. Pull it and start working. Nothing to install.

This replaces [r-bioinformatics-2026](https://github.com/armilner/r-bioinformatics-2026). That image stays available for anyone who needs to reproduce older results.

## What's new compared to 2026

- **R 4.6.1 and Bioconductor 3.23** (2026 had R 4.4.1 and Bioconductor 3.19).
- **Built on the official Bioconductor image**, so packages install as pre-built binaries. The build is faster and needs no compiler workarounds.
- **RStudio Server and Quarto are included.** You can render `.qmd` notebooks and open RStudio in a browser.
- **Much fuller single-cell coverage.** Added:

| Job | Packages added |
|---|---|
| Ambient RNA | SoupX, celda (decontX), DropletUtils |
| Doublets | scds, DoubletFinder (scDblFinder was already there) |
| Fast markers, large data | presto, BPCells |
| Cell type annotation | SingleR, celldex, Azimuth, UCell, AUCell, escape |
| Seurat extras | SeuratData, SeuratWrappers, SeuratDisk, scCustomize, SCpubr, clustree |
| Single-cell DE and abundance | MAST, miloR |
| Trajectories | slingshot, tradeSeq |
| Cell-cell communication | CellChat, nichenetr |
| TF and pathway activity | decoupleR, OmnipathR, dorothea, progeny |
| Copy number (tumour cells) | infercnv, copykat |
| Immune repertoire (VDJ) | scRepertoire |
| Spatial | SpatialExperiment, spacexr (RCTD) |
| Python formats (h5ad) | zellkonverter, LoomExperiment |

- **Also added outside single-cell:** apeglm, ashr, sva, bsseq, DSS, Gviz, JASPAR2024, EnsDb annotations, the mm39 TxDb, BSgenome hg38, and qs2.

The full list is in [`packages.txt`](packages.txt). The build checks every package on that list and fails if any one is missing.

## Usage

### On HPC with Apptainer (recommended)

```bash
# 1. Pull once
apptainer pull r-bioinformatics-2027.sif docker://ghcr.io/armilner/r-bioinformatics-2027:latest

# 2. Run a script
apptainer exec --bind /path/to/project r-bioinformatics-2027.sif Rscript /path/to/project/analysis.R

# 3. Render a Quarto notebook
apptainer exec --bind /path/to/project r-bioinformatics-2027.sif quarto render /path/to/project/analysis.qmd
```

Pulling builds a large `.sif` file. If the pull is killed, the converter ran out of memory or space. Run the pull inside a job with 30 GB of memory and point `APPTAINER_TMPDIR` at scratch:

```bash
export APPTAINER_TMPDIR=/path/to/scratch/apptainer-tmp
mkdir -p $APPTAINER_TMPDIR
```

`--bind` makes a folder visible inside the container. Bind every folder your script reads or writes, for example `--bind /data,/scratch`.

Example Slurm job:

```bash
#!/bin/bash
#SBATCH --job-name=my-analysis
#SBATCH -N 1 -n 1 -c 16 --mem=64G --time=4:00:00

SIF=/path/to/r-bioinformatics-2027.sif
apptainer exec --bind /path/to/project $SIF Rscript /path/to/project/analysis.R
```

### Locally with Docker

```bash
docker run --rm -it ghcr.io/armilner/r-bioinformatics-2027:latest R
```

RStudio in your browser:

```bash
docker run --rm -p 8787:8787 -e PASSWORD=choose-a-password \
    -v /path/to/project:/home/rstudio/project \
    ghcr.io/armilner/r-bioinformatics-2027:latest
```

Then open http://localhost:8787 (user `rstudio`, and the password you chose).

The image is built for x86-64 (Intel/AMD). On an Apple Silicon Mac, Docker runs it through emulation, which works but is slow.

### Adding a package without rebuilding

```r
dir.create("~/R/library", recursive = TRUE, showWarnings = FALSE)
.libPaths(c("~/R/library", .libPaths()))
BiocManager::install("extrapackage")
```

This keeps the extra package in your home folder, outside the container. For anything you use often, open an issue or a pull request that adds it to the `Dockerfile` and `packages.txt`.

## Build details

- **Base image:** bioconductor/bioconductor_docker:3.23-R-4.6.1 (Ubuntu 24.04)
- **R:** 4.6.1. **Bioconductor:** 3.23. **Quarto:** 1.10.19
- Built by GitHub Actions and pushed to the GitHub Container Registry on every change to `Dockerfile` or `packages.txt`. Tags: `latest`, the build month (`YYYY-MM`), and the commit (`sha-...`). Use the month or commit tag in papers, so your results always point to the exact same image.

## Citation

Use GitHub's **Cite this repository** button (top right of the About panel), or see [`CITATION.cff`](CITATION.cff).

## License

MIT.
