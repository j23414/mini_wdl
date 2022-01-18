version 1.0

import "tasks/nextstrain.wdl" as nextstrain

workflow Nextstrain_WRKFLW {
  input {
    File? build_yaml
    String indir = "zika-tutorial-master"              # ugly, but fix it later
    String giturl = "https://github.com/nextstrain/zika-tutorial/archive/refs/heads/master.zip"
    String docker_path = "nextstrain/base:latest"
  }

  call nextstrain.nextstrain_build as build {
    input:
      build_yaml = build_yaml,
      indir = indir,
      dockerImage = docker_path,
      giturl = giturl
  }

  output {
    Array[File] auspice_dir = build.auspice_dir 
  }
}