FROM continuumio/miniconda3

# docker build -f docker/Dockerfile -t vanessa/encode-demo-workflow .

LABEL maintainer vsochat@stanford.edu
ENV DEBIAN_FRONTEND=noninteractive
RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1 && \
    apt-get update && apt-get install -y \
    libncurses5-dev \
    libncursesw5-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    zlib1g-dev \
    git \
    gcc \
    wget \
    unzip \
    ghostscript \
    pkg-config \
    libboost-dev \
    openjdk-11-jre-headless \
    apt-transport-https \
    imagemagick \
&& rm -rf /var/lib/apt/lists/*

RUN wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip && \
    unzip Trimmomatic-0.38.zip && rm Trimmomatic-0.38.zip && \
    conda install pytest>=3.5.0 && \
    conda install numpy>=1.14.2 && \
    conda install scipy>=1.0.1 && \
    conda install pandas>=0.22.0 && \
    conda install matplotlib>=2.1.1 && \
    conda install biopython>=1.68 && \
    conda install pygraphviz && \
    conda install seaborn>=0.8.1 && \
    conda install -c bioconda -c conda-forge snakemake && \
    conda clean -afy && \
    mkdir -p /code

WORKDIR /code
ADD . /code
RUN cp docker/trimmomatic_alias.sh /usr/local/bin/trimmomatic && \
    chmod 0755 /usr/local/bin/trimmomatic

RUN chmod u+x /Trimmomatic-0.38/trimmomatic-0.38.jar
ENTRYPOINT ["snakemake"]
CMD ["--use-conda"]
