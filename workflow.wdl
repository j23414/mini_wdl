version 1.0

# import "tasks/nextstrain.wdl" as nextstrain # <= modular method
import "tasks/buildfile.wdl" as buildfile
#import "tasks/version1.wdl" as nextstrain
#import "tasks/version2.wdl" as nextstrain  # <= swap versions
import "tasks/s3.wdl" as nextstrain

workflow Nextstrain_WRKFLW {
  input {
    # Option 1: run the ncov example workflow
    File? build_yaml
    # Option 1b: add custom profiles
    File custom_zip
    # Pass in AWS KEYS (required!)
    String AWS_ACCESS_KEY_ID
    String AWS_SECRET_ACCESS_KEY

    # Option 2: create a build_yaml from sequence and metadata
    File? sequence_fasta
    File? metadata_tsv
    String? build_name
    # It's possible all of the above files are provided

    # Option 3? GISAID augur zip?
    # File? gisaid_zip # tarball

    String? active_builds # "Wisconsin,Minnesota,Iowa"

    # By default, run the ncov workflow (can swap it for zika or something else)
    String giturl = "https://github.com/nextstrain/ncov/archive/refs/heads/master.zip"
    String docker_path = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int? disk_size
  }

  if (defined(sequence_fasta)) {
    call buildfile.mk_buildconfig as mk_buildconfig {
      input:
        sequence_fasta = select_first([sequence_fasta]),
        metadata_tsv = select_first([metadata_tsv]),
        build = build_name,
        dockerImage = docker_path
    }
  }

  # call nextstrain.nextstrain build as build {  # <= modular method
  call nextstrain.nextstrain_build as build {
    input:
      build_yaml = select_first([build_yaml, mk_buildconfig.buildconfig]), # Accepts Option 1 or Option 2
      custom_zip = custom_zip,
      cpu = cpu,
      memory = memory,
      disk_size = disk_size,
      dockerImage = docker_path,
      giturl = giturl,
      active_builds = active_builds,
      AWS_ACCESS_KEY_ID = AWS_ACCESS_KEY_ID,
      AWS_SECRET_ACCESS_KEY = AWS_SECRET_ACCESS_KEY
  }

  output {
    #Array[File] json_files = build.json_files
    File auspice_zip = build.auspice_zip
    File results_zip = build.results_zip
  }
}
