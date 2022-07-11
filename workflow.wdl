version 1.0

#import "tasks/softwarename.wdl" as softwarename

# === Customized Object
struct My_Object {
  Int value
}

# === Define individual tasks

# Can be defined later in the file (order doesn't matter?)

task wdl_task {
  input {
    # Primitives
    Boolean a_truth = true
    String a_string = "AAAA"
    Int a_int = 20
    Float a_float = 1.111

    # Conditionals - (boolean = defined(conditional_var) or conditional_var == None or !=)
    String? maybe_string = "hope"
    File? maybe_file
    # Float? maybe_float = 1.111
    # File? maybe_file

    # Files or Directories
    File a_file
    # Directory a_directory # NOPE, still no directories on Terra
    Array[File] some_files = [ a_file ]

    # Collections, Maps, Pairs
    Map[String, String] a_map = {"color": "blue", "height": "6.6"}
    Pair[Int, String] a_pair = (1, "abc")

    # Customized struct
    My_Object custom_obj = object { value:111 }

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
    echo -e "String?\tmaybe_string\t~{maybe_string}"
    echo -e "File?\tmaybe_file~{maybe_file}"
    echo -e ""
  
    echo -e "====== Files/Directories"
    echo -e "~{a_file}"
    echo -e ""
  
    echo -e "====== Collections"  
    echo -e "Array[File]\tsome_files\t~{sep=" " some_files}"
    echo -e "Map[String,String]\ta_map\t" `cat "~{write_map(a_map)}" `
    echo -e "Pair[Int,String]\ta_pair\t~{a_pair.left} ~{a_pair.right}"
    echo -e ""
  
    echo -e "====== Custom Objects"
    echo -e "My_Object\tcustom_obj\t~{custom_obj.value}"
    
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

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int? disk_size
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
  scatter (in_str in some_strings) {
    call parallel_step {input: in=in_str }
  }
  call gather_step { input: ins=parallel_step.stdout }

  output {
    Array[File] outputs = wdl_task.outputs
    File env = wdl_task.env
    File text = wdl_task.text
    String stdout_str = wdl_task.stdout_str
    String gather_echo = gather_step.stdout
  }
}
