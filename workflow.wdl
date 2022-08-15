version 1.0

#import "tasks/softwarename.wdl" as softwarename

# === Customized Object
struct My_Object {
  Int value
  String name
  String? maybe_text
}

# === Define individual tasks

# Can be defined later in the file (order doesn't matter?)

task wdl_task {
  meta {
    author: "Jane Doe"
  }
  parameter_meta {
    # These parameters will be required, no optionals?
    a_truth: "Either true or false"
    a_file: "A tsv file for the example"
    maybe_truth: "this is an optional test"
  }
  input {
    # Primitives
    Boolean a_truth = true
    String a_string = "AAAA"
    Int a_int = 20
    Float a_float = 1.111

    # Conditionals - (boolean = defined(conditional_var) or conditional_var == None or !=)
    String? maybe_string
    File? maybe_file
    Boolean? maybe_truth
    # File? maybe_file

    # Files or Directories
    File a_file
    String file_base = basename(a_file)
    String file_stripped = basename(a_file, ".tsv")
    # Directory a_directory # NOPE, still no directories on Terra
    Array[File] some_files = [ a_file ]

    # Collections, Maps, Pairs
    Map[String, String] a_map = {"color": "blue", "height": "6.6"}
    Pair[Int, String] a_pair = (1, "abc")

    # Customized struct
    My_Object custom_obj = object { value:111, name:"bill" }

    # # Collections - String newvar = if length(collection_var) > 0 then xxx else xxx
    # Array[Boolean] group_truth = [ true, false ]
    # Array[String] group_string = [ "hello", "world" ]
    # Array[Int] group_int = [ 1, 2 ]
    # Array[Float] group_float = [1.1, 2.2]
    # Array[File] group_files = []

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
    echo -e "===== Primatives"
    echo -e "Boolean\ta_truth\t~{a_truth}"
    echo -e "String\ta_string\t~{a_string}"
    echo -e "Int\ta_int\t~{a_int}"
    echo -e "Float\ta_float\t~{a_float}"
    echo -e ""
  
    echo -e "===== Optionals"
    echo -e "String?\tmaybe_string\t~{default='empty' maybe_string}"
    echo -e "File?\tmaybe_file\t~{maybe_file}"
    echo -e "Boolean?\tmaybe_truth\t~{default='false' maybe_truth}"
    echo -e ""
  
    echo -e "====== Files/Directories"
    echo -e "File: ~{a_file}"
    echo -e "Basename: ~{basename(a_file)}"
    echo -e "Basename: ~{file_base}"
    echo -e "Stripped: ~{file_stripped}"
    echo -e ""
  
    echo -e "====== Collections"  
    echo -e "Array[File]\tsome_files\t~{sep=" " some_files}"
    echo -e "Map[String,String]\ta_map\t" `cat "~{write_map(a_map)}" `
    echo -e "Pair[Int,String]\ta_pair\t~{a_pair.left} ~{a_pair.right}"
    echo -e ""
  
    echo -e "====== Custom Objects"
    echo -e "My_Object\tcustom_obj\t~{custom_obj.value}\t~{custom_obj.name}\t~{default='empty' custom_obj.maybe_text}"
    
    touch a.txt b.txt c.txt
    env > env.txt
    ls -ltrh
  >>>

  output {
    Array[File] outputs = glob("*")
    File env = "env.txt"
    File text = select_first(glob("*.txt"))

    String stdout_str = read_string(stdout())
  }

  runtime {
    docker : docker_img
    cpu : select_first([cpu, 16])
    memory: select_first([memory, 50]) + " GiB"
    disks: "local-disk " + select_first([disk_size, 100]) + " HDD"
  }
}

# === Parallel steps (Scatter + Gather)
task parallel_step {
  input {
    String in = ""

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int? disk_size
  }
  command <<<
    echo ~{in} " parallel_step"
  >>>
  output {
    String stdout = read_string(stdout())
  }
  runtime {
    docker : docker_img
    cpu : select_first([cpu, 16])
    memory: select_first([memory, 50]) + " GiB"
    disks: "local-disk " + select_first([disk_size, 100]) + " HDD"
  }
}

task gather_step {
  input {
    Array[String] ins = []

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int? disk_size
  }
  command <<<
  echo ~{sep=" , " ins}
  >>>
  output {
    String stdout = read_string(stdout())
  }
  runtime {
    docker : docker_img
    cpu : select_first([cpu, 16])
    memory: select_first([memory, 50]) + " GiB"
    disks: "local-disk " + select_first([disk_size, 100]) + " HDD"
  }
}

task xz_task {
  input{
    File infile

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int disk_size = ceil(size(infile, "GB") * 2 + 1)
  }
  command<<<
    xz --version
    time xz -v ~{infile}
    ls -ltrh
  >>>
  output {
    Array[File] outfiles = glob("*")
  }

  runtime {
    docker : docker_img
    cpu : select_first([cpu, 16])
    memory: select_first([memory, 50]) + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }
}

task zstd_task {
  input{
    File infile

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int disk_size = ceil(size(infile, "GB") * 2 + 1)
  }
  command<<<
    zstd --version
    time zstd ~{infile}
    ls -ltrh
  >>>
  output {
    Array[File] outfiles = glob("*")
  }

  runtime {
    docker : docker_img
    cpu : select_first([cpu, 16])
    memory: select_first([memory, 50]) + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }
}

task looper {
  input {
    File? infile

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int disk_size = ceil(size(infile, "GB") * 2 + 1)

  }
  command <<<
  touch outfile.txt
  if [[ -n "~{infile}" ]]; then
    cat ~{infile} >> outfile.txt
  fi

  echo "looper: " `date` &>> outfile.txt
  >>>
  output {
    File outfile = "outfile.txt"
  }
  runtime {
    docker : docker_img
    cpu : select_first([cpu, 16])
    memory: select_first([memory, 50]) + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }

}

# Race

task running_man {
  input {
    String? in_str
    String text = "running man"
    Int speed = 1

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int disk_size = 5
  }
  command <<<
    sleep ~{speed}
    echo "~{in_str} ~{text}"
  >>>
  output {
    String out_str = read_string(stdout())
  }
  runtime {
    docker : docker_img
    cpu : select_first([cpu, 16])
    memory: select_first([memory, 50]) + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }
}

task get_stats {
  input {
    File fasta_xz
    File metadata_xz

    String filter = "region:Africa"

    String fasta = basename(fasta_xz, ".xz")
    String metadata = basename(metadata_xz, ".xz")

    String docker_img = "nextstrain/ncov-ingest:latest"
    Int? cpu
    Int? memory
    Int disk_size = 1 + 24 * ceil(size(fasta_xz, "GB") + size(metadata_xz, "GB"))
  }
  command <<<
    set -v
    echo "disk_size =" ~{disk_size}
    echo "metadata =" ~{metadata}
    echo "fasta =" ~{fasta}

    xz --version
    tsv-filter --version

    mkdir data
    xz --decompress --stdout ~{metadata_xz} \
      | tsv-filter -H --str-in-fld ~{filter} \
      | xz --stdout -2 > data/metadata_africa.tsv.xz

    ls -lh data/metadata_africa.tsv.xz

    xz --decompress --stdout data/metadata_africa.tsv.xz | wc -l

    # Get strain names for genomes.
    # GISAID uses virus name, collection date, and submission date
    # delimited by a pipe character.
    xz --decompress --stdout data/metadata_africa.tsv.xz \
      | tsv-select -H -f 'virus','date','date_submitted' \
      | sed 1d \
      | awk -F "\t" '{ print $1"|"$2"|"$3 }' > data/strains_africa.txt

    wget https://raw.githubusercontent.com/santiagosnchez/faSomeRecords/master/faSomeRecords.py

    xz --decompress --stdout ~{fasta_xz} \
      | python faSomeRecords.py --fasta /dev/stdin --list data/strains_africa.txt --stdout \
      | xz --stdout -2 > data/sequences_africa.fasta.xz

    xz --decompress --stdout data/sequences_africa.fasta.xz | grep -c ">"

    ls -lh data/metadata_africa.tsv.xz data/sequences_africa.fasta.xz
  >>>
  output {
    String out_str = read_string(stdout())
    File out_seq = "data/sequences_africa.fasta.xz"
    File out_met = "data/metadata_africa.tsv.xz"

    #File out_seq = fasta
    #File out_met = metadata
  }
  runtime {
    docker : docker_img
    cpu : select_first([cpu, 16])
    memory: select_first([memory, 50]) + " GiB"
    disks: "local-disk " + disk_size + " HDD"
  }
}

# === Link tasks in a workflow
workflow WRKFLW {
  input {
    # Primitives
    Boolean a_truth = true
    String a_string = "AAAA"
    Int a_int = 20
    Float a_float = 1.111

    File a_file

    Array[String] some_strings=["a", "b", "c"]

    File? large_file

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int? disk_size

    File fasta_xz
    File metadata_xz
  }

  call wdl_task {
    input:
      # Primitives
      a_truth = a_truth,
      a_string = a_string,
      a_int = a_int,
      a_float = a_float,
      a_file = a_file,

      # Required
      docker_img = docker_img,
      cpu = cpu,
      memory = memory,
      disk_size = disk_size,
  }
#  scatter (in_str in some_strings) {
#    call parallel_step {input: in=in_str }
#  }
#  call gather_step { input: ins=parallel_step.stdout }
#
#  if ( defined(large_file) ) {
#    call xz_task { input: infile= select_first([large_file])}
#    call zstd_task { input: infile= select_first([large_file])}
#  }
#
#  call looper as loop1
#  call looper as loop2 { input: infile=loop1.outfile }
#  call looper as loop3 { input: infile=loop2.outfile }
#
#  call running_man as Bill { input: in_str="", text="Bill won!", speed = 1}
#  call running_man as Jim { input: in_str="", text="Jim won!", speed = 10}

  call get_stats { input: fasta_xz = fasta_xz, metadata_xz = metadata_xz }

  output {
    Array[File] outputs = wdl_task.outputs
#    File env = wdl_task.env
#    File text = wdl_task.text
#    String stdout_str = wdl_task.stdout_str
#    String gather_echo = gather_step.stdout
#
#    Array[File]? xz_out = xz_task.outfiles
#    Array[File]? zstd_out = zstd_task.outfiles
#    File looped = loop3.outfile
#
#    # force collision here by connecting to same workspace
#    String bill_out = Bill.out_str
#    String jim_out = Jim.out_str

    String STATOUT = get_stats.out_str
    File sequences = get_stats.out_seq
    File metadata = get_stats.out_met
  }
}
