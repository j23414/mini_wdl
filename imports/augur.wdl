version 1.0

task index {
    command {
        augur index \
          --sequences {sequences} \
          --output {sequence_index} 2>&1 | tee {log}
    }

}

task filter { }

task tree {}

task refine {}

task ancestral {}

task distance {}

task traits {}

# task clade_files #<=== this is just a rename...

task clades {}  # add 2nd copy for emerging_lineages

task frequencies {} 

task distance {}

task export {}
