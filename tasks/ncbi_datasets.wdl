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

# REF: https://github.com/nextstrain/ncov-ingest/blob/ncbi-datasets/workflow/snakemake_rules/fetch_sequences.smk

task fetch_ncbi_dataset_package {
  input {
    String virus_name='SARS-CoV-2'
  }
  command<<<
    datasets download virus genome taxon ~{virus_name} --no-progressbar --filename ncbi_datasets.zip
  >>>
  output {
    File ncbi_dataset_sequences = 'ncbi_datasets.zip'
  }
  runtime {
    docker: 'staphb/ncbi-datasets:latest'
  }
}

task extract_ncbi_dataset_sequences {
  input {
    File dataset_package
  }
  command <<<
    unzip -jp ~{dataset_package} \
      ncbi_dataset/data/genomic.fna > ncbi_dataset_sequences.fasta
  >>>
  output {
    File ncbi_dataset_sequences="ncbi_dataset_sequences.fasta"
  }
  runtime {
    docker: 'ubuntu'
  }
}

task format_ncbi_dataset_report {
  input {
    File dataset_package
    String fields_to_include='accession,sourcedb,sra-accs,isolate-lineage,geo-region,geo-location,isolate-collection-date,release-date,update-date,virus-pangolin,length,host-common-name,isolate-lineage-source,biosample-acc,submitter-names,submitter-affiliation,submitter-country'
  }
  command <<<
    dataformat tsv virus-genome \
      --package ~{dataset_package} \
      --fields ~{fields_to_include} \
      > ncbi_dataset_report.tsv
  >>>
  output {
    File ncbi_dataset_tsv = 'ncbi_dataset_report.tsv'
  }
  runtime {
    docker: 'staphb/ncbi-datasets:latest'
  }
}

task create_genbank_ndjson {
  input {
    File ncbi_dataset_sequences
    File ncbi_dataset_tsv
  }
  command <<<
    augur curate passthru \
      --metadata ~{ncbi_dataset_tsv} \
      --fasta ~{ncbi_dataset_sequences} \
      --seq-id-column Accession \
      --seq-field sequence \
      --unmatched-reporting warn \
      --duplicate-reporting warn \
      > genbank.ndjson
  >>>
  output {
    File ndjson = 'genbank.ndjson'
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
  }
}