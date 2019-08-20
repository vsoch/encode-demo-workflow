# Snakemake workflow: ENCODE Demo Workflow

**under development**

[![Snakemake](https://img.shields.io/badge/snakemake-≥3.12.0-brightgreen.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/snakemake-workflows/encode-demo-workflow.svg?branch=master)](https://travis-ci.org/snakemake-workflows/encode-demo-workflow)

<p align="center">
<a href="https://www.encodeproject.org">
  <img style="float:left;" width="200" src="https://github.com/ENCODE-DCC/encode-data-usage-examples/blob/master/images/encodelogo.gif">
</a>
</p>

## Encode Snakemake

This is a Snakemake workflow to implement the previous [encode-demo-pipeline](https://github.com/ENCODE-DCC/demo-pipeline). Specifically, all ENCODE-DCC pipelines that are under [snakemake-workflows](https://www.github.com/snakemake-workflows) are in the format `encode-<name>-workflow`. Here you will find:

 - [Snakefile](Snakefile): is the main entrypoint
 - [config.yaml](config.yaml) is the configuration file that stores variables, the idea being that an implementation of the pipeline could customize it. You can read more about configuration files [here](https://snakemake.readthedocs.io/en/stable/snakefiles/configuration.html).
 - [schemas](schemas): Most of the configurations here are provided in yaml, and we need a way to validate those files. This folder contains json schemas used to validate those yaml files.
 - [scripts](scripts): includes supplementary scripts for the pipeline
 - [rules](rules): are included in the Snakefile, and provide a human friendly way to organize your steps. For example, the main task here is to run the trimming, so there is a [trimming.smk](rules/trimming.smk) file included.
 - [envs](envs): environment settings for runtime (?)

The pipeline demonstrates using the [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) software to trim input FASTQs. The output includes the trimmed FASTQ and a plot of FASTQ quality scores before and after trimming. For simplicity this demo supports only single-end FASTQs, however since we use the [trimmomatric snakemake-wrapper](https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/trimmomatic.html) it would be fairly easy to adjust for paired.

## Authors

* Vanessa Sochat (@vsoch)

## Development

How does it work?

### Samples.csv

While we *could* write input data as variables in [config.yaml](config.yaml), when the number of
inputs gets very large this becomes problematic. Instead, we can use a [samples.tsv](samples.tsv)
file that records our input data. For example, the file here contains:

```tsv
sample	condition
1	untreated
2	treated
```

The numbers "1" and "2" are variables that we want to carry around the pipeline to refer
to inputs and outputs. For example, our inputs are named accordingly:

```bash
$ ls data/reads/
file1.fastq.gz  file2.fastq.gz
```

And we would read in the table of samples (1,2) in the first [rules](rules) like so:

```python
import pandas
samples = pandas.read_csv("samples.tsv", sep="\t").set_index("sample", drop=False)
```

Notice that we set the index to "sample" to correspond with the column with 1 and 2.

### Validation

All of the content in [schemas](schemas) is for validation. For example, after
reading in the samples in the section above, we might want to validate that variable,
ensuring that fields are defined, and of a particular type. Snakemake provides a function
to make it easy for us to do this:

```python
from snakemake.utils import validate
validate(samples, schema="../schemas/samples.schema.yaml")
```

And so logically, we also do this in the first run of our [rules](rules/common.smk).
You wouldn't want to proceed with a pipeline if there is missing data.

### Snakemake Wrappers

In [rules](rules) files you'll notice that a lot of the sections have an attribute for a "wrapper."
These are [snakemake-wrappers](https://snakemake-wrappers.readthedocs.io) that you literally 
can copy paste into one of your files to use, making it easy to develop workflows. 
For example, this unique resource identifier:

```yaml
...
    wrapper:
        "0.36.0/bio/trimmomatic/se"
```

corresponds to [trimmomatic](https://snakemake-wrappers.readthedocs.io/en/stable/wrappers/trimmomatic/se.html)
version 0.36.0. If you are thinking ahead, you are correct that it would be highly
useful to develop snakemake-wrappers for tasks that you see repeating more than once, or
that you want to make easy for other researchers to use.

## Usage

### Simple

#### Step 1: Install workflow

If you simply want to use this workflow, download and extract the [latest release](https://github.com/snakemake-workflows/encode-demo-workflow/releases).
If you intend to modify and further extend this workflow or want to work under version control, fork this repository as outlined in [Advanced](#advanced). The latter way is recommended.

In any case, if you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repository and, if available, its DOI (see above).

#### Step 2: Configure workflow

Configure the workflow according to your needs via editing the file `config.yaml`.

#### Step 3: Execute workflow

Test your configuration by performing a dry-run via

    snakemake --use-conda -n

Execute the workflow locally via

    snakemake --use-conda --cores $N

using `$N` cores or run it in a cluster environment via

    snakemake --use-conda --cluster qsub --jobs 100

or

    snakemake --use-conda --drmaa --jobs 100

If you not only want to fix the software stack but also the underlying OS, use

    snakemake --use-conda --use-singularity

in combination with any of the modes above.
See the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/executable.html) for further details.

# Step 4: Investigate results

After successful execution, you can create a self-contained interactive HTML report with all results via:

    snakemake --report report.html

This report can, e.g., be forwarded to your collaborators.

### Advanced

The following recipe provides established best practices for running and extending this workflow in a reproducible way.

1. [Fork](https://help.github.com/en/articles/fork-a-repo) the repo to a personal or lab account.
2. [Clone](https://help.github.com/en/articles/cloning-a-repository) the fork to the desired working directory for the concrete project/run on your machine.
3. [Create a new branch](https://git-scm.com/docs/gittutorial#_managing_branches) (the project-branch) within the clone and switch to it. The branch will contain any project-specific modifications (e.g. to configuration, but also to code).
4. Modify the config, and any necessary sheets (and probably the workflow) as needed.
5. Commit any changes and push the project-branch to your fork on github.
6. Run the analysis.
7. Optional: Merge back any valuable and generalizable changes to the [upstream repo](https://github.com/snakemake-workflows/encode-demo-workflow) via a [**pull request**](https://help.github.com/en/articles/creating-a-pull-request). This would be **greatly appreciated**.
8. Optional: Push results (plots/tables) to the remote branch on your fork.
9. Optional: Create a self-contained workflow archive for publication along with the paper (snakemake --archive).
10. Optional: Delete the local clone/workdir to free space.


## Testing

Tests cases are in the subfolder `.test`. They are automtically executed via continuous integration with Travis CI.

## Not in Use

The following sections I originally started implementing here, but I think they are overkill for
what we want to do (so I didn't implement).

### Samples.csv

While we *could* write input data as variables in [config.yaml](config.yaml), when the number of
inputs gets very large this becomes problematic. Instead, we can use a [samples.tsv](samples.tsv)
file that records our input data. And then we can read in (in our first rule) like so:

```python
import pandas as pd
samples = pd.read_table("samples.tsv").set_index("samples", drop=False)
```

I didn't implement this off the bat because it's not obvious how the samples that
are read in can then further populate
