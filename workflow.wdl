version 1.0

import "tasks/nextstrain.wdl" as nextstrain

workflow Nextstrain_WRKFLW {
  input {
    # Option 1: run the ncov example workflow
    File? build_yaml

    # Option 2: create a build_yaml from sequence and metadata
    File? sequence_fasta
    File? metadata_tsv

    # Option 3? GISAID augur zip?
    # File? gisaid_zip

    # By default, run the ncov workflow (can swap it for zika or something else)
    String giturl = "https://github.com/nextstrain/ncov/archive/refs/heads/master.zip"
    String docker_path = "nextstrain/base:latest"
  }

  if (defined(sequence_fasta)) {
    call mk_buildconfig {
      input:
        sequence_fasta = select_first([sequence_fasta]),
        metadata_tsv = select_first([metadata_tsv]),
        dockerImage = docker_path
    }
  } 

  call nextstrain.nextstrain_build as build {
    input:
      build_yaml = select_first([build_yaml, mk_buildconfig.buildconfig]), # Accepts Option 1 or Option 2
      dockerImage = docker_path,
      giturl = giturl
  }

  output {
    Array[File] json_files = build.json_files
    File auspice_zip = build.auspice_zip
  }
}

# === Draft tasks here, move to module later
task mk_buildconfig {
  input {
    File sequence_fasta  # Could change this to Array[File] and loop the HEREDOC
    File metadata_tsv
    String build = "example"
    String dockerImage
    Int cpu = 1
    Int disk_size = 5   # Pretty sure a cat command doesn't need much memory
    Float memory = 3.5
  }
  command {
    cat << EOF > build.yaml
    inputs:
    - name: ~{build}
      metadata: ~{metadata_tsv}
      sequences: ~{sequence_fasta}
    - name: references
      metadata: data/references_metadata.tsv
      sequences: data/references_sequences.fasta
    EOF
  }
  output {
    File buildconfig = "build.yaml"
  }
  runtime {
    docker: dockerImage
    cpu : cpu
    memory: memory + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }
}

# Public Reference Datasets
# nextstrain remote ls s3://nextstrain-data/files/ncov/open &> list.txt
# files/ncov/open/LOCATION/metadata.tsv.xz where LOCATION = one of ['africa', 'asia', 'europe', 'global', 'north-america', 'oceania', 'south-america']
# files/ncov/open/LOCATION/sequences.fasta.xz
# TODO: since these are all s3, just generate string (avaid download and localazation/delocalization) for the mk_buildconfig
# Clarification: Do these need to be sampled down?