version 1.0

task git_pull_ncov {
  input {
    String giturl = "https://github.com/nextstrain/ncov/archive/refs/tags/v9.zip"  # Git is not installed in Dockerfile:"https://github.com/nextstrain/ncov.git"
  }
  command {
    wget ~{giturl}
    unzip v9.zip
    mv ncov-9 ncov
  }
  output {
    File ncov_path = "ncov"
  }
  runtime {
    docker : "nextstrain/base:latest"
  }
}