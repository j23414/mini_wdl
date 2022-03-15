version 1.0

task nextstrain_build {
  input {
    File? build_yaml
    File custom_zip # <= since custom is private
    String? active_builds # Wisconsin,Minnesota,Washington
    String dockerImage = "nextstrain/base:latest"
    String nextstrain_app = "nextstrain"
    String giturl = "https://github.com/nextstrain/ncov/archive/refs/heads/master.zip"
    # String? custom_url = "path to public github"  # Our custom config files are private
    Int cpu = 8         # Honestly, I'd max this out unless budget is a consideration.
    Int disk_size = 30  # In GiB.  Could also check size of sequence or metadata files
    Float memory = 3.5 
  }
  command {
    # Pull ncov, zika or similar repository
    wget -O master.zip ~{giturl}
    INDIR=`unzip -Z1 master.zip | head -n1 | sed 's:/::g'`
    unzip master.zip  

    # Link custom profile (zipped version)
    mv ~{custom_zip} here_custom.zip
    CUSTOM_DIR=`unzip -Z here_custom.zip | head -n1 | sed 's:/::g'`
    unzip here_custom.zip
    cp -r $CUSTOM_DIR/*_profile $INDIR/.
    BUILDYAML=`ls -1 $CUSTOM_DIR/*.yaml | head -n1`
    
    # Max out the number of threads
    PROC=`nproc`  

    # Run nextstrain
    "~{nextstrain_app}" build \
      --cpus $PROC \
      --memory  ~{memory}Gib \
      --native $INDIR \
      --configfile $BUILDYAML \
      ~{"--config active_builds=" + active_builds}
    
    # --native $INDIR ~{"--configfile " + build_yaml} \
      
    # Prepare output
    mv $INDIR/auspice .
    zip -r auspice.zip auspice
  }
  output {
    File auspice_zip = "auspice.zip"
    Array[File] json_files = glob("auspice/*.json")
    # Target the s3
  }
  runtime {
    docker: dockerImage
    cpu : cpu
    memory: memory + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }
}

# Drafting thoughts, there are better ways to organizine this
# task nextstrain_specific_build {
#   input {
#     File? build_yaml
#     File? sequence_fasta
#     File? metadata_tsv
#     File? 
#     String? active_builds # Wisconsin,Minnesota,Washington
#     String? deploy_url    # s3, if aws credentials work, data.nextstrain.org
#     String dockerImage = "nextstrain/base:latest"
#     String nextstrain_app = "nextstrain"
#     String ncov_url = "https://github.com/nextstrain/ncov/archive/refs/heads/master.zip"
#     String specific_url = "https://github.com/nextstrain/ncov-africa-cdc/archive/refs/heads/main.zip"
#     Int cpu = 8         # Honestly, I'd max this out unless budget is a consideration.
#     Int disk_size = 30  # In GiB.  Could also check size of sequence or metadata files
#     Float memory = 3.5 
#   }
#   command {
#     # Pull ncov, zika or similar repository
#     wget -O master.zip ~{ncov_url}
#     INDIR=`unzip -Z1 master.zip | head -n1 | sed 's:/::g'`
#     unzip master.zip  
# 
#     # Pull specific configs
#     wget -O main.zip ~{specific_url}
#     SPEC_INDIR=`unzip -Z1 main.zip | head -n1 | sed 's:/::g'`
#     unzip main.zip
# 
#     ln -s $SPEC_INDIR/*_profile $INDIR/.
# 
#     ~{"mv " + sequence_fasta + " $INDIR/data/."}
#     ~{"mv " + metadata_tsv + " $INDIR/data/."}
#     
#     # Max out the number of threads
#     PROC=`nproc`  
# 
#     # Run nextstrain
#     "~{nextstrain_app}" build \
#       --cpus $PROC \
#       --memory  ~{memory} \
#       --native $INDIR ~{"--configfile " + build_yaml} \
#       ~{"--config active_builds=" + active_builds}
#       # deploy upload # Target of the snakemake set to s3
#       
#     # Prepare output
#     mv $INDIR/auspice .
#     zip -r auspice.zip auspice
#   }
#   output {
#     File auspice_zip = "auspice.zip"
#     Array[File] json_files = glob("auspice/*.json")
#   }
#   runtime {
#     docker: dockerImage
#     cpu : cpu
#     memory: memory + " GiB"
#     disks: "local-disk " + disk_size + " HDD"
#   }
# }
# 