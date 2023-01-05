version 1.0

import "https://raw.githubusercontent.com/j23414/wdl_pathogen_build/main/tasks/ingest.wdl" as ingest

workflow INGEST {
  input {
    Int ncbi_taxon_id = 186536
  }

  call ingest.fetch_general_geolocation_rules {}
  
  call ingest.fetch_from_genbank {
    input:
      ncbi_taxon_id=ncbi_taxon_id
  }
  call ingest.transform_field_names {
    input:
      ndjson=fetch_from_genbank.genbank_ndjson
  }
  call ingest.transform_strain_names {
    input:
      ndjson=transform_field_names.out_ndjson
  }
  call ingest.transform_date_fields {
    input:
      ndjson=transform_strain_names.out_ndjson
  }
  call ingest.transform_genbank_location {
    input:
      ndjson=transform_date_fields.out_ndjson
  }
  call ingest.transform_string_fields2 {
    input:
      ndjson=transform_genbank_location.out_ndjson
  }
  call ingest.transform_authors {
    input:
      ndjson=transform_string_fields2.out_ndjson
  }
  call ingest.apply_geolocation_rules {
    input:
      ndjson=transform_authors.out_ndjson,
      all_geolocation_rules=fetch_general_geolocation_rules.general_geolocation_rules
  }
  call ingest.merge_user_metadata {
    input:
      ndjson=apply_geolocation_rules.out_ndjson
  }
  call ndjson_to_tsv_and_fasta {
    input:
      ndjson=merge_user_metadata.out_ndjson
  }
  call ingest.post_process_metadata {
    input:
      metadata=ndjson_to_tsv_and_fasta.metadata
  }

  output {
    File sequences = ndjson_to_tsv_and_fasta.sequences
    File metadata = post_process_metadata.out_metadata
  }
}