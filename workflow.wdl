version 1.0


# === Define individual tasks

# Can be defined later in the file (order doesn't matter?)

task drop_first_task {
  meta {
    author: "Jane Doe"
  }
  parameter_meta {
    a_file: "A tsv file for the example"
  }
  input {

    # Files or Directories
    File a_file
    String file_base = basename(a_file)

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int? disk_size
  }

  command <<<
    echo "default shell: " $SHELL
    pwd
    ls -ltrh *
  
    echo -e "====== Files/Directories"
    echo -e "File: ~{a_file}"
    echo -e "Basename: ~{basename(a_file, '.tsv')}"
    echo -e ""

    echo "Drop first line"
    sed '1d' ~{a_file} > ~{basename(a_file, '.tsv')}_modified.tsv
  
    touch a.txt b.txt c.txt
    env > env.txt
    ls -ltrh
  >>>

  output {
    File env = "env.txt"
    File outfile = select_first(glob("*_modified.tsv"))
  }

  runtime {
    docker : docker_img
    cpu : select_first([cpu, 16])
    memory: select_first([memory, 50]) + " GiB"
    disks: "local-disk " + select_first([disk_size, 100]) + " HDD"
  }
}

# === Link tasks in a workflow
workflow WRKFLW {
  input {
    File a_file

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int? disk_size
  }

  call drop_first_task {
    input:
      a_file = a_file,

      # Required
      docker_img = docker_img,
      cpu = cpu,
      memory = memory,
      disk_size = disk_size,
  }

  output {
    File env = drop_first_task.env
    File outfile = drop_first_task.outfile
  }
}
