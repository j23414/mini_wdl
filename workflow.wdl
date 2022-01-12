version 1.0
# https://docs.dockstore.org/en/develop/advanced-topics/best-practices/wdl-best-practices.html

# Option 1: As one wrapped task
import "tasks/nextstrain.wdl" as nextstrain
# Option 2: As individual modules
# import "tasks/augur.wdl" as augur
# import "tasks/ncov.wdl" as ncov

workflow Nextstrain_WRKFLW {
  input {
    String indir = "zika-tutorial-master"              # ugly, but fix it later
    String outfile = "zika"
    String giturl = "https://github.com/nextstrain/zika-tutorial/archive/refs/heads/master.zip"
    String docker_path = "nextstrain/base:latest"
  }

  call nextstrain.nextstrain_build as build {
    input:
      indir = indir,
      outfile = outfile,
      dockerImage = docker_path,
      giturl = giturl
  }

  output {
    File auspice_dir = build.auspice_dir 
  }
}