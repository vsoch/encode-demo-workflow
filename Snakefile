include: "rules/common.smk"

# The main entry point of your workflow.
# After configuring, running snakemake -n in a clone of this repository should successfully execute a dry-run of the workflow.

configfile: "config.yaml"
report: "report/workflow.rst"

# Allow users to fix the underlying OS via singularity.
singularity: "docker://vanessa/encode-demo-workflow:latest"
docker: "vanessa/encode-demo-workflow:latest"

rule all:
    input:
        # This rule defines the default target files (what needs to be created)
        # Subsequent target rules can be specified below. They should start with all_*.
        expand(["data/trimmed/trimmed.file{sample}.fastq.gz"], sample=samples.index),
        expand(["data/file{sample}_untrimmed_file{sample}_trimmed_quality_scores.png"], sample=samples.index)

include: "rules/trimming.smk"
include: "rules/plot.smk"
