version 1.0

task pathogen_build {
  input{
    String pathogen_giturl = "https://github.com/nextstrain/zika/archive/refs/heads/main.zip"
    Int cpu = 8
    Int disk_size = 30 # Gb
    Float memory = 3.5
  }
  command <<<
    echo "cpu: ~{cpu} ; disk_size: ~{disk_size} ; memory: ~{memory}"
    wget -O pathogen.zip ~{pathogen_giturl}
    INDIR=`unzip -Z1 pathogen.zip | head -n1 | sed 's:/::g'`
    unzip pathogen.zip

    cd $INDIR
    nextstrain build --native .

    cd ..
    mv $INDIR/auspice .
    zip -r auspice.zip auspice

    mv $INDIR/results .
    cp $$INDIR/.snakemake/log/*.log results/.
    zip -r results.zip results

    LAST_RUN=`date +%F`
    echo ${LAST_RUN} > LAST_RUN
  >>>
  output{
    File auspice_zip = "auspice.zip"
    File results_zip = "results.zip"
    String last_run = read_string("LAST_RUN")
  }
  runtime{
    docker: 'nextstrain/base:latest'
    cpu : cpu
    memory: memory + ' GiB'
    disks: 'local-disk ' + disk_size + ' HDD'
  }
}

task pathogen_ingest {
  input{
    String pathogen_giturl = "https://github.com/nextstrain/dengue/archive/refs/heads/ingest.zip"
    Int cpu = 8
    Int disk_size = 30 # Gb
    Float memory = 3.5
  }
  command <<<
    echo "cpu: ~{cpu} ; disk_size: ~{disk_size} ; memory: ~{memory}"
    wget -O pathogen.zip ~{pathogen_giturl}
    INDIR=`unzip -Z1 pathogen.zip | head -n1 | sed 's:/::g'`
    unzip pathogen.zip

    cd $INDIR/ingest
    nextstrain build --native .
    cd ../..

    mv $INDIR/ingest/data .
    ls -ltr data/*
  >>>
  output{
    Array [File] sequences_fastas = glob("data/*.fasta")
    Array [File] metadata_tsvs = glob("data/*.tsv")
  }
  runtime{
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : cpu
    memory: memory + ' GiB'
    disks: 'local-disk ' + disk_size + ' HDD'
  }
}