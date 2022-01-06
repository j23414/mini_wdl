version 1.0

# Import augur tasks
import "augur.wdl" as augur

# Zika default workflow
workflow zika_workflow {
    input {
        File input_fasta = "./zika/data/sequences.fasta"
        File input_metadata = "./zika/data/metadata.fasta"
        File exclude = "./zika/data/dropped_sequences.fasta"
        File reference = "./Zika/data/reference.gb"
        File colors = "./Zika/data/colors.tsv"
        File lat_longs = "./Zika/data/lat_longs.tsv"
        File auspice_config = "./Zika/configs/auspice_config.json"
        String docker_path = "nextstrain/base:latest"
    }

    call augur.IndexSequences as IndexSequences {
        input:
            input_fasta = input_fasta,
            dockerImage = docker_path

    }
    call augur.Filter as Filter {
        input:
            input_fasta = input_fasta,
            sequence_index = IndexSequences.sequence_index,
            input_metadata = input_metadata,
            exclude = exclude,
            dockerImage = docker_path
    }
    call augur.Align as Align {
        input:
            filtered_sequences = Filter.filtered_sequences,
            reference = reference,
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
            input_metadata = input_metadata,
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
            reference = reference,
            dockerImage = docker_path
    }
    call augur.Traits as Traits {
        input:
            time_tree = Refine.time_tree,
            input_metadata = input_metadata,
            dockerImage = docker_path
    }
    call augur.Export as Export {
        input:
            time_tree = Refine.time_tree,
            input_metadata = input_metadata,
            branch_lengths = Refine.branch_lengths,
            traits = Traits.traits,
            nt_muts = Ancestral.nt_muts,
            aa_muts = Translate.aa_muts,
            colors = colors,
            lat_longs = lat_longs,
            auspice_config = auspice_config,
            dockerImage = docker_path
    }

    output {
        File auspice_json = Export.auspice_json
    }
}