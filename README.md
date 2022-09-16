# A WDL Pathogen Build - Array to DataTable

**DO NOT MERGE!!!!**

Convert a Array[File] terra object into a tsv which can be imported as a Terra DataTable. This can simplify parallizable code if there is no expectation of a "gather" step at the end.

```
echo -e  "~{sep=" " some_files}" > datatable.tsv
```


## Links

* [Dockstore: j23414/wdl\_pathogen\_build:array\_to\_datatable](https://dockstore.org/workflows/github.com/j23414/wdl_pathogen_build:array_to_datatable?tab=info)
