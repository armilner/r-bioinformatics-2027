FROM bioconductor/bioconductor_docker:3.23-R-4.6.1

LABEL maintainer="Andrew Milner"
LABEL description="Comprehensive R bioinformatics container: single-cell, spatial, bulk RNA-seq, methylation, ATAC-seq, and pathway analysis (2027)"
LABEL org.opencontainers.image.source="https://github.com/armilner/r-bioinformatics-2027"

# The Bioconductor base image already has R 4.6.1, Bioconductor 3.23, RStudio Server,
# pandoc, and pre-built Linux binaries for CRAN and Bioconductor packages, so most
# installs below download a binary instead of compiling.

ENV QUARTO_VERSION=1.10.19

# ── System libraries ──────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    libhdf5-dev libxml2-dev libssl-dev libcurl4-openssl-dev \
    libgsl-dev libfftw3-dev libglpk-dev \
    libpng-dev libjpeg-dev libtiff-dev libmagick++-dev \
    libbz2-dev liblzma-dev zlib1g-dev \
    libgdal-dev libgeos-dev libproj-dev libudunits2-dev \
    jags \
    cmake git curl \
    && rm -rf /var/lib/apt/lists/*

# ── Quarto CLI (renders .qmd notebooks) ───────────────────────────────────────
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL -o /tmp/quarto.deb \
      "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${ARCH}.deb" && \
    dpkg -i /tmp/quarto.deb && rm /tmp/quarto.deb && quarto --version

# ── Core CRAN: data, parallelism, plotting, reporting ─────────────────────────
RUN R -e "install.packages(c( \
    'tidyverse', 'data.table', 'Matrix', 'qs2', \
    'future', 'future.apply', 'parallelly', \
    'Rcpp', 'RcppArmadillo', 'RcppEigen', \
    'scales', 'viridis', 'RColorBrewer', 'circlize', \
    'ggrepel', 'patchwork', 'cowplot', 'ggpubr', 'ggridges', 'gridExtra', \
    'pheatmap', 'hdf5r', 'igraph', 'leidenbase', 'RANN', \
    'rmarkdown', 'knitr', 'quarto', 'remotes', 'msigdbr', 'metap' \
))"

# ── Bioconductor infrastructure and annotation ────────────────────────────────
RUN R -e "BiocManager::install(c( \
    'SummarizedExperiment', 'SingleCellExperiment', 'SpatialExperiment', \
    'GenomicRanges', 'GenomicFeatures', 'GenomicAlignments', 'Rsamtools', 'rtracklayer', \
    'AnnotationDbi', 'AnnotationHub', 'ExperimentHub', 'biomaRt', \
    'rhdf5', 'HDF5Array', 'DelayedArray', 'LoomExperiment', 'BiocParallel', 'BiocNeighbors', \
    'org.Hs.eg.db', 'org.Mm.eg.db', 'org.Rn.eg.db', 'GO.db', \
    'EnsDb.Hsapiens.v86', 'EnsDb.Mmusculus.v79', \
    'TxDb.Hsapiens.UCSC.hg38.knownGene', 'TxDb.Mmusculus.UCSC.mm10.knownGene', \
    'TxDb.Mmusculus.UCSC.mm39.knownGene', 'BSgenome.Hsapiens.UCSC.hg38' \
), ask = FALSE, update = FALSE)"

# ── Single-cell: core, QC, ambient RNA, doublets ──────────────────────────────
RUN R -e "install.packages(c('Seurat', 'SeuratObject', 'sctransform', 'harmony', \
    'presto', 'SoupX', 'clustree', 'scCustomize', 'SCpubr', 'UCell'))"
RUN R -e "BiocManager::install(c( \
    'scran', 'scater', 'scuttle', 'bluster', 'batchelor', 'glmGamPoi', \
    'DropletUtils', 'celda', 'scDblFinder', 'scds', \
    'SingleR', 'celldex', 'MAST', 'AUCell', 'zellkonverter', \
    'dittoSeq', 'Nebulosa', 'schex' \
), ask = FALSE, update = FALSE)"

# ── Single-cell: abundance, trajectories, communication, TF activity, CNV, VDJ ─
RUN R -e "BiocManager::install(c( \
    'speckle', 'miloR', 'muscat', \
    'slingshot', 'tradeSeq', \
    'decoupleR', 'OmnipathR', 'dorothea', 'progeny', \
    'infercnv', 'scRepertoire', 'escape' \
), ask = FALSE, update = FALSE)"

# ── Single-cell: GitHub-only packages ─────────────────────────────────────────
RUN R -e "remotes::install_github(c( \
    'bnprks/BPCells/r', \
    'satijalab/seurat-data', \
    'satijalab/seurat-wrappers', \
    'mojaveazure/seurat-disk', \
    'chris-mcginnis-ucsf/DoubletFinder', \
    'cole-trapnell-lab/monocle3', \
    'jinworks/CellChat', \
    'saeyslab/nichenetr', \
    'dmcable/spacexr', \
    'navinlabcode/copykat' \
), upgrade = 'never')"
RUN R -e "remotes::install_github('satijalab/azimuth', upgrade = 'never')"

# ── Bulk RNA-seq and differential expression ──────────────────────────────────
RUN R -e "BiocManager::install(c( \
    'DESeq2', 'edgeR', 'limma', 'apeglm', 'ashr', \
    'tximport', 'tximeta', 'DEXSeq', 'variancePartition', 'sva' \
), ask = FALSE, update = FALSE)"

# ── Gene sets and pathways ────────────────────────────────────────────────────
RUN R -e "BiocManager::install(c( \
    'clusterProfiler', 'DOSE', 'enrichplot', 'ReactomePA', 'pathview', \
    'fgsea', 'GSEABase', 'GSVA', 'qvalue', 'multtest' \
), ask = FALSE, update = FALSE)"

# ── ATAC-seq and chromatin ────────────────────────────────────────────────────
RUN R -e "install.packages('Signac')" && \
    R -e "BiocManager::install(c( \
    'chromVAR', 'motifmatchr', 'TFBSTools', 'JASPAR2024', \
    'DiffBind', 'ChIPseeker' \
), ask = FALSE, update = FALSE)"

# ── Methylation ───────────────────────────────────────────────────────────────
RUN R -e "BiocManager::install(c( \
    'minfi', 'methylKit', 'bsseq', 'DSS', 'DMRcate', 'sesame', 'ENmix', 'missMethyl' \
), ask = FALSE, update = FALSE)"

# ── Visualization ─────────────────────────────────────────────────────────────
RUN R -e "BiocManager::install(c('ComplexHeatmap', 'EnhancedVolcano', 'Gviz'), \
    ask = FALSE, update = FALSE)"

# ── Co-expression (needs preprocessCore and impute from Bioconductor) ─────────
RUN R -e "BiocManager::install(c('preprocessCore', 'impute'), ask = FALSE, update = FALSE)" && \
    R -e "install.packages('WGCNA')"

# ── Verify: the build fails if any package is missing ─────────────────────────
COPY packages.txt /opt/packages.txt
RUN R -e " \
pkgs <- readLines('/opt/packages.txt'); \
pkgs <- trimws(pkgs[nzchar(trimws(pkgs)) & !startsWith(trimws(pkgs), '#')]); \
missing <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]; \
if (length(missing) > 0) stop('Build failed. Missing packages: ', paste(missing, collapse = ', ')); \
ip <- installed.packages()[, 'Version']; \
for (p in pkgs) cat(sprintf('%-40s %s\n', p, ip[p])); \
cat('All', length(pkgs), 'packages verified.\n') \
" && quarto --version
