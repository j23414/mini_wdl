version 1.0

import 'https://raw.githubusercontent.com/j23414/wdl_pathogen_build/main/tasks/pathogen_build.wdl' as dengue_tasks

workflow DENGUE_WORKFLOW {
  call dengue_tasks.pathogen_build as dengue_build{
    input: pathogen_giturl = 'https://github.com/nextstrain/dengue/archive/refs/heads/main.zip'
  }

  output {
    File auspice_zip = dengue_build.auspice_zip
    File results_zip = dengue_build.results_zip
  }
}