version 1.0

import "https://raw.githubusercontent.com/j23414/wdl_pathogen_build/main/tasks/pathogen_build.wdl" as pathogen

workflow PATHOGEN_WORKFLOW {
  input {
    String pathogen_giturl = 'https://github.com/nextstrain/zika/archive/refs/heads/main.zip'
  }
  call pathogen.pathogen_build as build {
    input: pathogen_giturl = pathogen_giturl
  }

  output {
    File auspice_zip = build.auspice_zip
    File results_zip = build.results_zip
    String last_run = build.last_run
  }
}