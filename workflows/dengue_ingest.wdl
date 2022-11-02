version 1.0

import 'https://raw.githubusercontent.com/j23414/wdl_pathogen_build/main/tasks/pathogen_build.wdl' as dengue_tasks

workflow DENGUE_WORKFLOW {
  call dengue_tasks.pathogen_ingest as dengue_ingest{
    input: pathogen_giturl = 'https://github.com/nextstrain/dengue/archive/refs/heads/ingest.zip'
  }

  output {
    Array [File] sequences_fastas = dengue_ingest.sequences_fastas
    Array [File] metadata_tsvs = dengue_ingest.metadata_tsvs
  }
}