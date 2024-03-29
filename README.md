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

**Importantly** this pipeline is not intended to run on your host. For complete reproducibility, we 
use containers. While some think that using conda is enough for reproducibility, I do not.

## Authors

* Vanessa Sochat (@vsoch)

## Development

How does it work?

### Snakefile

The main [Snakemake](Snakemake) file is like the entrypoint to your workflow. At the top
there are (akin to a Makefile) there is a "make all" section that will list (or expand
patterns) to generate the files that should be produced after running the workflow.

### Rules

Rules are other tasks in the workflow that are organized in the [rules](rules)
folder. Each is included in the Snakefile to add to be run. The logic of running
things comes down to looking at the inputs and outputs for rules, and running
them accordingly to generate the final expected outputs. 

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
We could then feed this index (including both 1 and 2) into a variable to populate an input:

```python
sample=samples.index
```

For this example, we don't actually use the second column (condition) but it's provided as an
example (we could!).

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

### Step 1: Download the Repository

If you simply want to use this workflow, first clone the repository:

```bash
$ git clone https://www.github.com/vsoch/encode-demo-workflow
```

### Step 2: Configure workflow

If you want to change configuration options, edit the `config.yaml`.
Otherwise, we will demo usage using the default already built into the
container.

### Step 3: Execute workflow

#### Singularity 

For this example, we will use [Singularity](https://sylabs.io/guides/latest/user-guide/)
as it's most likely you will want to run this using HPC.

You can pull the container:

```bash
$ singularity pull docker://quay.io/vanessa/encode-demo-workflow
```

And first test the default configuration by performing a dry-run via

```bash
$ singularity run encode-demo-workflow_latest.sif -n
```

And then run the workflow:

```bash
$ singularity run encode-demo-workflow_latest.sif
```

The output files will be in data/trimmed/, assuming that you run the workflow
from the repository with the local files bound. You can also generate a report!
In the example below, we render an "index.html" to render the report on the
master branch via GitHUb pages:

```bash
$ singularity run encode-demo-workflow_latest.sif --report index.html
```

And then clean up:

```bash
$ singularity run encode-demo-workflow_latest.sif --delete-all-output
```

If you want to run this with a job manager, just put the entire command in
a single script. The native --cluster commands doin't work with this approach.

#### Docker

To execute the same workflow using Docker, we have more isolation from the host.
We can run the default provided in the container:

```bash
$ docker run quay.io/vanessa/encode-demo-workflow -n
```

To run the workflow (entirely in the container):

```bash
$ docker run quay.io/vanessa/encode-demo-workflow
```

To bind output to the host:

```bash
$ docker run -v $PWD/data/trimmed:/code/data/trimmed quay.io/vanessa/encode-demo-workflow
```

or bind the entire present working directory to be used in the container:

```bash
$ docker run -v $PWD:/code quay.io/vanessa/encode-demo-workflow
``` 

and for a report:

```bash
$ docker run -v $PWD:/code quay.io/vanessa/encode-demo-workflow --report /code/index.html
``` 

The report generated will use the root of the repository as the web root so you
will want to generate it as index.html to render on GitHub pages.

## Development

If you want to build a container that is used in the example above, there is 
a [Dockerfile](docker/Dockerfile) that is used as a base for Singularity and Docker. The difference
from the main Encode container is that we don't install Python 2, and we create an alias for trimmomatic
so that the Snakemake wrapper will work. If you need to build the Docker container (and this should
be provided for the user in Docker Hub):

```bash
$ docker build -f docker/Dockerfile -t quay.io/vanessa/encode-demo-workflow .
```

And then we pull to the host via Singularity, or Docker. 

The expectation is that the container includes all dependencies for the workflow,
including a `trimmomatic` binary. For this particular container, we create an
executable that forwards the command to the .jar (Java) file.


See the [Snakemake documentation](https://snakemake.readthedocs.io/en/stable/executable.html) for further details.

##### Locally

Execute the workflow locally via

```bash
$ snakemake --use-conda --cores $N
```

*below not tested yet*

using `$N` cores or run it in a cluster environment via


#### Step 4: Investigate results

I consider it a bug that the report generation cannot be done [using the container](https://github.com/vsoch/encode-demo-workflow/issues/4)
so for now this isn't designed. But typically, after successful execution, you can create a self-contained interactive HTML report with all results via:

```bash
$ snakemake --report report.html
```

The command we would want to work is:

```bash
$ snakemake --use-singularity --report report.html
```

This report can, e.g., be forwarded to your collaborators.

# Step 5: Clean Up

If you want to clean up output (to try a different backend, or otherwise just remove
the files) you can do:

```bash
$ snakemake --delete-temp-output
$ snakemake --delete-all-output
Building DAG of jobs...
Deleting data/trimmed/trimmed.file1.fastq.gz
Deleting data/trimmed/trimmed.file2.fastq.gz
Deleting data/file1_untrimmed_file1_trimmed_quality_scores.png
Deleting data/file2_untrimmed_file2_trimmed_quality_scores.png
```

And then have a clean slate to start again.

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

Tests cases are in the subfolder `.test`. They are automatically executed via continuous integration with Travis CI.
