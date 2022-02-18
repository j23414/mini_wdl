version 1.0

# Drafting thoughts here

task ncov_ingest {
  input {
    # based off of https://github.com/nextstrain/ncov-ingest#required-environment-variables
    String GISAID_API_ENDPOINT
    String GISAID_USERNAME_AND_PASSWORD
    String AWS_DEFAULT_REGION
    String AWS_ACCESS_KEY_ID
    String AWS_SECRET_ACCESS_KEY
    String? SLACK_TOKEN
    String? SLACK_CHANNEL

    String giturl = "https://github.com/nextstrain/ncov-ingest/archive/refs/heads/master.zip"

    String? docker_img = "nextstrain/base:latest"
    Int cpu = 16
    Int disk_size = 48  # In GiB
    Float memory = 3.5
  }

  command <<<
    # Set up env variables
    GISAID_API_ENDPOINT=~{GISAID_API_ENDPOINT}
    GISAID_USERNAME_AND_PASSWORD=~{GISAID_USERNAME_AND_PASSWORD}
    AWS_DEFAULT_REGION=~{AWS_DEFAULT_REGION}
    AWS_ACCESS_KEY_ID=~{AWS_ACCESS_KEY_ID}
    AWS_SECRET_ACCESS_KEY=~{AWS_SECRET_ACCESS_KEY}

    # ditto for slack tokens but add a optional wrapper

    # Pull ncov-ingest repo
    wget -O master.zip ~{giturl}
    NCOV_INGEST_DIR=`unzip -Z1 master.zip | head -n1 | sed 's:/::g'`
    unzip master.zip

    PROC=`nproc` # Max out processors, although not sure if it matters here

    # Um... well call the snakemake
    cd ${NCOV_INGEST_DIR}

    # Best guess from https://github.com/nextstrain/ncov-ingest/blob/master/.github/workflows/fetch-and-ingest-gisaid-master.yml#L43
    ./bin/write-envdir env.d \
      AWS_DEFAULT_REGION \
      GISAID_API_ENDPOINT \
      GISAID_USERNAME_AND_PASSWORD \
      # GITHUB_RUN_ID \
      # SLACK_TOKEN \
      # SLACK_CHANNELS \
      # PAT_GITHUB_DISPATCH

    declare -a config
    config+=(
      fetch_from_database=True
      trigger_rebuild=True
    )

    nextstrain build \
      --aws-batch \
      --no-download \
      --image nextstrain/ncov-ingest \
      --cpus ~{PROC} \
      --memory ~{memory}GiB \
      --exec env \
      . \
        envdir env.d snakemake \
          --configfile config/gisaid.yaml \
          --config "${config[@]}" \
          --cores ${PROC} \
          --resources mem_mb=47000 \
          --printshellcmds

    # Okay, where does 47000 go?

    # Or maybe simplier? https://github.com/nextstrain/ncov-ingest/blob/master/.github/workflows/rebuild-open.yml#L26
    ./bin/rebuild open
    ./bin/rebuild gisaid

    # === prepare output
    cd ..
    zip -r ncov_ingest.zip ${NCOV_INGEST_DIR}
  >>>

  output {
    File ncov_ingest_zip = "ncov_ingest.zip"
    # Separate this out into sequences, metadata files for both open and closed
  }
  
  runtime {
    docker: docker_img
    cpu : cpu
    memory: memory + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }

}