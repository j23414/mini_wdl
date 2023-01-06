version 1.0

workflow NCBI_DATASETS {
  input {
    String virus_name='zika'
  }
  call ncbi_datasets {
    input:
      virus_name=virus_name
  }
  output {
    Array[File] outfiles=ncbi_datasets.outfiles
  }
}

task ncbi_datasets {
  input {
    String virus_name='zika'
  }
  command <<<
    datasets download virus genome taxon ~{virus_name}
  >>>
  output {
    Array[File] outfiles = glob("*")
  }
  runtime {
    docker: 'staphb/ncbi-datasets:latest'
    cpu: 8
    memory: '4 GiB'
    disks: 'local-disk 100 HDD'
  }
}