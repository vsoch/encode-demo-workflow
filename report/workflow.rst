This pipeline demonstrates using the `Trimmomatic`_ software to trim input FASTQs. The output includes the trimmed FASTQ and a plot of FASTQ quality scores before and after trimming. For simplicity this demo supports only single-end FASTQs, however since we use the `trimmomatic snakemake-wrapper`_ it would be fairly easy to adjust for paired.

Configuration options include:

 - Samples: {{ snakemake.config["samples"] }}
 - Trimmers: {{ snakemake.config["toy"]["trimmers"]|join(', ') }}
 - Extra Arguments: {{ snakemake.config["toy"]["extra"] }}
 - Compression Level: {{ snakemake.config["toy"]["compression_level"] }}

Plotting options include:

 - Bar Color: {{ snakemake.config["plot"]["bar_color"] }}
 - Flier Color: {{ snakemake.config["plot"]["flier_color"] }}
 - Plot Color: {{ snakemake.config["plot"]["plot_color"] }}

This is report generated from a Snakemake workflow. See `here`_ for details.

.. _Trimmomatic: http://www.usadellab.org/cms/?page=trimmomatic
.. _trimmomatic snakemake-wrapper: https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/trimmomatic.html
.. _here: https://snakemake.readthedocs.io/en/stable/snakefiles/reporting.html
