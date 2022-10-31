version 1.0

import "https://raw.githubusercontent.com/j23414/wdl_pathogen_build/main/tasks/pathogen_build.wdl" as measles_tasks

workflow MEASLES_WORKFLOW {
  call measles_tasks.pathogen_build as measles_build {
    input: pathogen_giturl = 'https://github.com/nextstrain/measles/archive/refs/heads/main.zip'
  }

  output {
    File auspice_zip = measles_build.auspice_zip
    File results_zip = measles_build.results_zip
  }
}