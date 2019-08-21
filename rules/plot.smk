# Plotting rules imported into the main Snakefile

rule plot:
    input:
        expand("data/trimmed/{sample}.fastq.gz", sample=samples.index) # 1,2
    output:
        "data/file{sample}_untrimmed_file{sample}_trimmed_quality_scores.png"
    params:
        scripts_dir=scripts
        flier_color=config['plot']['flier_color']
        plot_color=config['plot']['plot_color']
        bar_color=config['plot']['bar_color']
    log:
        "logs/plot/{sample}.log"
    shell:
        python3 scripts/plot_fastq_scores.py \
        --untrimmed {input} \
        --trimmed {output} \
        --bar-color {bar_color} \
        --flier-color {flier_color} \
        --plot-color {plot_color}
