version 1.0

task pull_ncov {
  input {
    String giturl = "https://github.com/nextstrain/ncov/archive/refs/tags/v10.zip"  # Git is not installed in Dockerfile:"https://github.com/nextstrain/ncov.git"
    String docker_img = "nextstrain/base:latest"
  }
  command {
    wget ~{giturl}
    mv v10.zip ncov.zip
  }
  output {
    File ncov_path = "ncov.zip"
  }
  runtime {
    docker : docker_img
  }
}

task pull_zika {
  input {
    String giturl = "https://github.com/nextstrain/zika-tutorial/archive/refs/heads/master.zip"
    String docker_img = "nextstrain/base:latest"
  }
  command {
    wget ~{giturl}
    mv master.zip zika-tutorial.zip
  }
  output {
    File zika_path = "zika-tutorial.zip"
  }
  runtime {
    docker : docker_img
  }
}