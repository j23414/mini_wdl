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
    cp ~{custom_zip} here_custom.zip
    CUSTOM_DIR=`unzip -Z1 here_custom.zip | head -n1 | sed 's:/::g'`
    unzip here_custom.zip
    cp -r $CUSTOM_DIR/*_profile $INDIR/.

    # Draft: if passing build file from zip folder
    # BUILDYAML=`ls -1 $CUSTOM_DIR/*.yaml | head -n1`
    # cp $BUILDYAML $INDIR/build_custom.yaml # --config build_custom.yaml
    
    # Max out the number of threads
    PROC=`nproc`  

    # Run nextstrain
    "~{nextstrain_app}" build \
      --cpus $PROC \
      --memory  ~{memory}Gib \
      --native $INDIR ~{"--configfile " + build_yaml} \
      ~{"--config active_builds=" + active_builds}
      
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
