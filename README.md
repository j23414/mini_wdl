# A WDL Pathogen Build - drop first

**DO NOT MERGE!!!!**

Will drop the first line from a given input file.

```
sed 1d ~{a_file} > outfile
```

Some pipelines produce a metadata fle with an extra line at the top. This is a temporary hack to address that issue.

## Links

* [Dockstore: j23414/wdl\_pathogen\_build:zzz\_min](https://dockstore.org/workflows/github.com/j23414/wdl_pathogen_build:drop_first?tab=info)

