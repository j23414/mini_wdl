version 1.0

import "tasks/nextstrain.wdl" as nextstrain

workflow Nextstrain_WRKFLW {
  input {
    File? build_yaml
    String giturl = "https://github.com/nextstrain/zika-tutorial/archive/refs/heads/master.zip"
    String docker_path = "nextstrain/base:latest"
  }

  call nextstrain.nextstrain_build as build {
    input:
      build_yaml = build_yaml,
      dockerImage = docker_path,
      giturl = giturl
  }

  output {
    Array[File] auspice_dir = build.auspice_dir 
  }
}