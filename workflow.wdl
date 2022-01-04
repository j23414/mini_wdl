version 1.0
# https://docs.dockstore.org/en/develop/advanced-topics/best-practices/wdl-best-practices.html

# Option 1: As individual modules
import "tasks/augur.wdl" as augur
# Option 2: As one wrapped task
import "tasks/nextstrain.wdl" as nextstrain
import "tasks/ncov.wdl" as ncov

# Modified https://github.com/nextstrain/zika-tutorial/blob/wdl/wdl/zika-tutorial.wdl
# + moved tasks to modules
# + pass in docker path to each of the tasks (instead of hardcoded)

# TODO: Wrap a script in a wdl task
# TODO: Export task should accept Tree or Tree + other output
# TODO: Get output files out of cromwell-execution, to an easier to reach place
# TODO: Add slurm run or config and have an easy way to switch between Terra/slurm/aws?

# workflow ZikaTutorial {
#     input {
#         File input_fasta
#         File input_metadata
#         File exclude
#         File reference
#         File colors
#         File lat_longs
#         File auspice_config
#         String docker_path
#     }
# 
#     call augur.IndexSequences as IndexSequences {
#         input:
#             input_fasta = input_fasta,
#             dockerImage = docker_path
# 
#     }
#     call augur.Filter as Filter {
#         input:
#             input_fasta = input_fasta,
#             sequence_index = IndexSequences.sequence_index,
#             input_metadata = input_metadata,
#             exclude = exclude,
#             dockerImage = docker_path
#     }
#     call augur.Align as Align {
#         input:
#             filtered_sequences = Filter.filtered_sequences,
#             reference = reference,
#             dockerImage = docker_path
#     }
#     call augur.Tree as Tree {
#         input:
#             alignment = Align.alignment,
#             dockerImage = docker_path
#     }
#     call augur.Refine as Refine {
#         input:
#             tree = Tree.tree,
#             alignment = Align.alignment,
#             input_metadata = input_metadata,
#             dockerImage = docker_path
#     }
#     call augur.Ancestral as Ancestral {
#         input:
#             time_tree = Refine.time_tree,
#             alignment = Align.alignment,
#             dockerImage = docker_path
#     }
#     call augur.Translate as Translate {
#         input:
#             time_tree = Refine.time_tree,
#             nt_muts = Ancestral.nt_muts,
#             reference = reference,
#             dockerImage = docker_path
#     }
#     call augur.Traits as Traits {
#         input:
#             time_tree = Refine.time_tree,
#             input_metadata = input_metadata,
#             dockerImage = docker_path
#     }
#     call augur.Export as Export {
#         input:
#             time_tree = Refine.time_tree,
#             input_metadata = input_metadata,
#             branch_lengths = Refine.branch_lengths,
#             traits = Traits.traits,
#             nt_muts = Ancestral.nt_muts,
#             aa_muts = Translate.aa_muts,
#             colors = colors,
#             lat_longs = lat_longs,
#             auspice_config = auspice_config,
#             dockerImage = docker_path
#     }
# 
#     output {
#         File auspice_json = Export.auspice_json
#     }
# }

# workflow Nextstrain_WRKFLW {
#     input {
#         File input_dir
#         String docker_path
#     }
# 
#     call nextstrain.nextstrain_build as build {
#         input:
#             input_dir = input_dir,
#             dockerImage = docker_path
#     }
# 
#     output {
#         File auspice_dir = build.auspice_dir
#     }
# }

workflow Pull {
    call ncov.git_pull_ncov as git_pull_ncov
    
    output {
        File ncov_path = git_pull_ncov.ncov_path
    }
}