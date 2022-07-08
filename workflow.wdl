version 1.0

#import "tasks/nextstrain.wdl" as nextstrain

struct My_Object {
  Int value
}

workflow WRKFLW {
  input {
    # Primitives
    Boolean a_truth = true
    String a_string = "AAAA"
    Int a_int = 20
    Float a_float = 1.111

    File a_file
    #Directory a_directory # Nope, still no directories on Terra
    
    # # Collections - String newvar = if length(collection_var) > 0 then xxx else xxx
    # Array[Boolean] group_truth = [ true, false ]
    # Array[String] group_string = [ "hello", "world" ]
    # Array[Int] group_int = [ 1, 2 ]
    # Array[Float] group_float = [1.1, 2.2]
    # Array[File] group_files = []
    # Array[Directory] group_directory = []
# 
    # # Conditionals - (boolean = defined(conditional_var) or conditional_var == None or !=)
    # String? maybe_string = None
    # Int? maybe_int = 20
    # Float? maybe_float = 1.111
    # File? maybe_file
# 
    # Array[String]? group_string
    # Array[Int]? group_int
    # Array[Float] group_float
    # Array[File] group_files

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

  output {
    Array[File] outputs = wdl_task.outputs
  }
}

# Can be defined later in the file (order doesn't matter?)

task wdl_task {
  input {
    # Primitives
    Boolean a_truth = true
    String a_string = "AAAA"
    Int a_int = 20
    Float a_float = 1.111

    File a_file

    Array[File] some_files = [ a_file ]
    Map[String, String] a_map = {"color": "blue", "height": "6.6"}
    Pair[Int, String] a_pair = (1, "abc")

    # Customized struct
    My_Object custom_obj = object { value:111 }

    # Required
    String docker_img = "nextstrain/base:latest"
    Int? cpu
    Int? memory       # in GiB
    Int? disk_size
  }

  command <<<
  echo $SHELL
  pwd
  ls -ltr *
  echo -e "===== Primatives"
  echo -e "Boolean\ta_truth\t~{a_truth}"
  echo -e "String\ta_string\t~{a_string}"
  echo -e "Int\ta_int\t~{a_int}"
  echo -e "Float\ta_float\t~{a_float}"
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