version 1.0

workflow WRKFLW {
  input {
    Array[File] some_files
  }

  call array_to_datatable {
    input: some_files = some_files
  }

  output {
    File datatable_tsv = array_to_datatable.datatable_tsv
  }
}

task array_to_datatable {
  input {
    Array[File] some_files
  }

  command <<<
    echo "default shell: " $SHELL
    pwd
    ls -ltrh *
  
    echo -e "====== Collections"  
    echo -e "Array[File]\tsome_files\t~{sep=" " some_files}"
    echo -e ""

    echo -e "entity:datatablenamehere_id\tinfile" > datatable.tsv

    ARR=("~{sep=" " some_files}")

    for FILE in "${ARR[@]}"; do
      echo -e `basename $FILE` "\t$FILE" >> datatable.tsv
    done

    ls -ltrh
  >>>

  output {
    File datatable_tsv = "datatable.tsv"
  }

  runtime {
    docker : 'ubuntu:latest'
    cpu : 16
    memory: "50 GiB"
    disks: "local-disk 100 HDD"
  }
}

