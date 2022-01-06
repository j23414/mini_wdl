version 1.0
# https://docs.dockstore.org/en/develop/advanced-topics/best-practices/wdl-best-practices.html

# Option 1: As one wrapped task
import "tasks/nextstrain.wdl" as nextstrain
# Option 2: As individual modules
import "tasks/augur.wdl" as augur


import "tasks/ncov.wdl" as ncov

# Modified https://github.com/nextstrain/zika-tutorial/blob/wdl/wdl/zika-tutorial.wdl
# + moved tasks to modules
# + pass in docker path to each of the tasks (instead of hardcoded)

# TODO: Wrap a script in a wdl task
# TODO: Export task should accept Tree or Tree + other output
# TODO: Add slurm run or config and have an easy way to switch between Terra/slurm/aws?

workflow Nextstrain_WRKFLW {
  input {
    # Option 1 Input
    File? input_dir

    # Option 2 Input
    File? input_fasta
    File? input_metadata
    File? exclude
    File? reference
    File? colors
    File? lat_longs
    File? auspice_config

    # Both
    Boolean pullncovflag = false
    String docker_path = "nextstrain/base:latest"
  }

  # Optional pre-run step, pull data/scripts from a github repo
  if (pullncovflag) {
    call ncov.pull_zika as pull_zika

    call nextstrain.nextstrain_build as builda {
      input:
        input_dir = pull_zika.zika_path,
        dockerImage = docker_path
    }
  }

  # Option 1: Wrap everything if input_dir is defined
  if (defined(input_dir) && !pullncovflag ) {
    call nextstrain.nextstrain_build as build {
      input:
        input_dir = select_first([input_dir]),
        dockerImage = docker_path
    }
  } # No else statements? Weird

  # Option 2: Run it one by one if not
  if (!defined(input_dir) && !pullncovflag) {
    call augur.IndexSequences as IndexSequences {
      input:
        input_fasta = select_first([input_fasta]),
        dockerImage = docker_path

    }
    call augur.Filter as Filter {
      input:
        input_fasta = select_first([input_fasta]),
        sequence_index = IndexSequences.sequence_index,
        input_metadata = select_first([input_metadata]),
        exclude = select_first([exclude]),
        dockerImage = docker_path
    }
    call augur.Align as Align {
      input:
        filtered_sequences = Filter.filtered_sequences,
        reference = select_first([reference]),
        dockerImage = docker_path
    }
    call augur.Tree as Tree {
      input:
        alignment = Align.alignment,
        dockerImage = docker_path
    }
    call augur.Refine as Refine {
      input:
        tree = Tree.tree,
        alignment = Align.alignment,
        input_metadata = select_first([input_metadata]),
        dockerImage = docker_path
    }
    call augur.Ancestral as Ancestral {
      input:
        time_tree = Refine.time_tree,
        alignment = Align.alignment,
        dockerImage = docker_path
    }
    call augur.Translate as Translate {
      input:
        time_tree = Refine.time_tree,
        nt_muts = Ancestral.nt_muts,
        reference = select_first([reference]),
        dockerImage = docker_path
    }
    call augur.Traits as Traits {
      input:
        time_tree = Refine.time_tree,
        input_metadata = select_first([input_metadata]),
        dockerImage = docker_path
    }
    call augur.Export as Export {
      input:
        time_tree = Refine.time_tree,
        input_metadata = select_first([input_metadata]),
        branch_lengths = Refine.branch_lengths,
        traits = Traits.traits,
        nt_muts = Ancestral.nt_muts,
        aa_muts = Translate.aa_muts,
        colors = select_first([colors]),
        lat_longs = select_first([lat_longs]),
        auspice_config = select_first([auspice_config]),
        dockerImage = docker_path
    }
  }

  output {
    File auspice_dir = select_first([builda.auspice_dir, build.auspice_dir, Export.auspice_json])
#    File auspice_dir = "~{if defined(build.auspice_dir) then build.auspice_dir else Export.auspice_json}"
  }
}

# workflow Pull {
#     call ncov.git_pull_ncov as git_pull_ncov
#     
#     output {
#         File ncov_path = git_pull_ncov.ncov_path
#     }
# }