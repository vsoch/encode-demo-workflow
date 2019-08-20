# The main entry point of your workflow.
# After configuring, running snakemake -n in a clone of this repository should successfully execute a dry-run of the workflow.


configfile: "config.yaml"
report: "report/workflow.rst"

# Allow users to fix the underlying OS via singularity.
singularity: "docker://continuumio/miniconda3"

rule all:
    input:
        # This rule defines the default target files (what needs to be created)
        # Subsequent target rules can be specified below. They should start with all_*.
        expand(["data/trimmed/trimmed.file{group}.fastq.gz", group=[1, 2]),
        expand(["data/report/file{group}_untrimmed_file{group}_trimmed_quality_scores.png"])

include: "rules/trimming.smk"
