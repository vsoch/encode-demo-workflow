# Plotting rules imported into the main Snakefile

rule plot:
    input:
        expand("data/trimmed/{sample}.fastq.gz", sample=samples.index) # 1,2
    output:
        "data/file{sample}_untrimmed_file{sample}_trimmed_quality_scores.png"
    params:
        flier_color=config["plot"]["flier_color"],
        plot_color=config["plot"]["plot_color"],
        bar_color=config["plot"]["bar_color"]
    log:
        "logs/plot/{sample}.log"
    shell:
        'python3 scripts/plot_fastq_scores.py --untrimmed {input} --trimmed {output} --bar-color {params.bar_color} --flier-color {params.flier_color} --plot-color {params.plot_color}'
