version 1.0

task pull_ncov {
  input {
    String giturl = "https://github.com/nextstrain/ncov/archive/refs/tags/v10.zip"  # Git is not installed in Dockerfile:"https://github.com/nextstrain/ncov.git"
    String docker_img = "nextstrain/base:latest"
  }
  command {
    wget ~{giturl}
    unzip v10.zip
    mv ncov-10 ncov
  }
  output {
    File ncov_path = "ncov"
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
    unzip master.zip
    mv zika-tutorial-master zika-tutorial
  }
  output {
    File zika_path = "zika-tutorial"
  }
  runtime {
    docker : docker_img
  }
}