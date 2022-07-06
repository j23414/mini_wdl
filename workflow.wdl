version 1.0

#import "tasks/nextstrain.wdl" as nextstrain

workflow Nextstrain_WRKFLW {
  input {
    # Primitives
    Boolean a_truth = true
    String a_string = "AAAA"
    Int a_int = 20
    Float a_float = 1.111

    File a_file
    Directory a_directory
    
    # Collections - String newvar = if length(collection_var) > 0 then xxx else xxx
    Array[Boolean] group_truth = [ true, false ]
    Array[String] group_string = [ "hello", "world" ]
    Array[Int] group_int = [ 1, 2 ]
    Array[Float] group_float = [1.1, 2.2]
    Array[File] group_files = []
    Array[Directory] group_directory = []

    # Conditionals - (boolean = defined(conditional_var) or conditional_var == None or !=)
    String? maybe_string = None
    Int? maybe_int = 20
    Float? maybe_float = 1.111
    File? maybe_file

    Array[String]? group_string
    Array[Int]? group_int
    Array[Float] group_float
    Array[File] group_files

    # Required
    String docker_path = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int? disk_size
  }

  call nextstrain.nextstrain_build as build {
    input:
      # Option 1
      sequence_fasta = sequence_fasta,
      metadata_tsv = metadata_tsv,
      context_targz = context_targz,
      build_name = build_name,

      # Option 2
      configfile_yaml = configfile_yaml,
      custom_zip = custom_zip,
      active_builds = active_builds,

      # Optional deploy to s3 site
      s3deploy = s3deploy,
      AWS_ACCESS_KEY_ID = AWS_ACCESS_KEY_ID,
      AWS_SECRET_ACCESS_KEY = AWS_SECRET_ACCESS_KEY,

      pathogen_giturl = pathogen_giturl,
      dockerImage = docker_path,
      cpu = cpu,
      memory = memory,
      disk_size = disk_size
  }

  output {
    File auspice_zip = build.auspice_zip
  }
}

task wdl_task {
  in
}