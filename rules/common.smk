import pandas
from snakemake.utils import validate

samples = pandas.read_csv("samples.tsv", sep="\t").set_index("sample", drop=False)
validate(samples, schema="../schemas/samples.schema.yaml")
