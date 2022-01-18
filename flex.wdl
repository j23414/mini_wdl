version 1.0
# Modified from: https://github.com/nextstrain/zika-tutorial/blob/wdl/wdl/zika-tutorial.wdl
# https://docs.dockstore.org/en/develop/advanced-topics/best-practices/wdl-best-practices.html

# Option 1: As one wrapped task
import "tasks/nextstrain.wdl" as nextstrain
# Option 2: As individual modules
import "tasks/augur.wdl" as augur

workflow Nextstrain_WRKFLW {
  input {
    # flex_input_1.json
    File? input_dir

    # flex_input_2.json
    File? input_fasta
    File? input_metadata
    File? exclude
    File? reference
    File? colors
    File? lat_longs
    File? auspice_config

    # Both
    String docker_path = "nextstrain/base:latest"
  }

  # Option 1: Wrap everything if input_dir is defined
  if (defined(input_dir)) {
    call nextstrain.nextstrain_build as build {
      input:
        #input_dir = select_first([input_dir]),
        dockerImage = docker_path
    }
  } # No else statements? Weird

  # Option 2: Run it one by one if not
  if (!defined(input_dir)) {
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
    File auspice_dir = select_first([ build.auspice_dir, Export.auspice_json])
  }
}