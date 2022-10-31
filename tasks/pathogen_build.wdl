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
    nextstrain build .
    cd ..
    mv $INDIR/auspice .
    zip -r auspice.zip auspice

    mv $INDIR/results .
    cp $$INDIR/.snakemake/log/*.log results/.
    zip -r results.zip results
  >>>
  output{
    File auspice_zip = "auspice.zip"
    File results_zip = "results.zip"
  }
  runtime{
    docker: "nextstrain/base:latest"
    cpu : cpu
    memory: memory + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }
}