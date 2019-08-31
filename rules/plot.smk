# Plotting rules imported into the main Snakefile

rule plot:
    input:
        untrimmed="data/reads/file{sample}.fastq.gz",
        trimmed="data/trimmed/trimmed.file{sample}.fastq.gz"
    output:
         "data/file{sample}_untrimmed_file{sample}_trimmed_quality_scores.png"
    params:
        flier_color=config["plot"]["flier_color"],
        plot_color=config["plot"]["plot_color"],
        bar_color=config["plot"]["bar_color"]
    log:
        "logs/plot/{sample}.log"
    shell:
        'python3 scripts/plot_fastq_scores.py --untrimmed "{input.untrimmed}" --trimmed "{input.trimmed}" --bar-color {params.bar_color} --flier-color {params.flier_color} --plot-color {params.plot_color} --output-dir data/'
