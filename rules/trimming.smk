# Trimming rules imported into the main Snakefile
# see https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/trimmomatic/se.html
# If you use the Singularity container, Trimmomatric is set to version 0.38

rule trimmomatic:
    input:
        expand("data/reads/file{sample}.fastq.gz", sample=samples.index) # 1,2
    output:
        "data/trimmed/{sample}.fastq.gz"
    log:
        "logs/trimmomatic/{sample}.log"
    params:
        # list of trimmers
        trimmer=config['toy']['trimmers'],
        # optional parameters
        extra=config['toy']['extra'],
        # optional compression levels
        compression_level=config['toy']['compression_level']
    threads:
        32
    wrapper:
        "0.36.0/bio/trimmomatic/se"
