# Process for each subcommand (nextclade -h)

# Given a dataset name, return nextclade dataset folder
task dataset_get {
  input {
      String dataset_name
  }
  command {
      nextclade dataset get \
      --name '${dataset_name}' \
      --output-dir '${dataset_name}'
  } 
  output {
      File dataset_path = dataset_name
  }
}

# Given a dataset and a query, return a folder of clades
task nextclade_run {
  input {
      File dataset
      File query
  } 
  command {
    nextclade run \
    --input-fasta ${query} \
    --input-dataset ${dataset} \
    --output-dir ${query.simpleName}_clades
  }
  output {
      File clades_file = "${query.simpleName}_clades"
  }
}

# Subworkflow specific for pulling sars-cov-2 datasets and query
workflow nextclade_sars_cov_2 {
  input {
      File query_ch
  }
  call dataset_get { 
      input { dataset_name = 'sars-cov-2' }
  }

  call nextclade_run { 
      input {
          File dataset = dataset_get.dataset_path
          File query = query_ch
      }
  }

  output {
      File NC_outfile = nextclade_run.clades_file
  }
}

# Subworkflow for any virus
# workflow nextclade {
#   take:
#     dataset_ch
#     query_ch
#   main:
#     dataset_ch | get_dataset | combine(query_ch) | nextclade_run
#   emit:
#     nextclade_run.out
# }