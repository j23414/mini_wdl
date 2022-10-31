version 1.0

import "https://raw.githubusercontent.com/j23414/wdl_pathogen_build/main/tasks/pathogen_build.wdl" as zika_tasks

workflow ZIKA_WORKFLOW {
  call zika_tasks.pathogen_build as zika_build {
    input: pathogen_giturl = 'https://github.com/nextstrain/zika/archive/refs/heads/main.zip'
  }

  output {
    File auspice_zip = zika_build.auspice_zip
    File results_zip = zika_build.results_zip
  }
}