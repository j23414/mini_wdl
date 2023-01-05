version 1.0

workflow INGEST {
  input {
    Int ncbi_taxon_id = 186536
  }

  call fetch_general_geolocation_rules {}
  
  call fetch_from_genbank {
    input:
      ncbi_taxon_id=ncbi_taxon_id
  }
  call transform_field_names {
    input:
      ndjson=fetch_from_genbank.genbank_ndjson
  }
  call transform_strain_names {
    input:
      ndjson=transform_field_names.out_ndjson
  }
  call transform_date_fields {
    input:
      ndjson=transform_strain_names.out_ndjson
  }
  call transform_genbank_location {
    input:
      ndjson=transform_date_fields.out_ndjson
  }
  call transform_string_fields2 {
    input:
      ndjson=transform_genbank_location.out_ndjson
  }
  call transform_authors {
    input:
      ndjson=transform_string_fields2.out_ndjson
  }
  call apply_geolocation_rules {
    input:
      ndjson=transform_authors.out_ndjson,
      all_geolocation_rules=fetch_general_geolocation_rules.general_geolocation_rules
  }
  call merge_user_metadata {
    input:
      ndjson=apply_geolocation_rules.out_ndjson
  }
  call ndjson_to_tsv_and_fasta {
    input:
      ndjson=merge_user_metadata.out_ndjson
  }
  call post_process_metadata {
    input:
      metadata=ndjson_to_tsv_and_fasta.metadata
  }
  
  output {
    File sequences = ndjson_to_tsv_and_fasta.sequences
    File metadata = post_process_metadata.out_metadata
  }
}

task fetch_from_genbank {
  input{
    Int ncbi_taxon_id = 186536
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/genbank-url https://raw.githubusercontent.com/nextstrain/dengue/ingest/ingest/bin/genbank-url
    curl -fsSL --output bin/fetch-from-genbank https://raw.githubusercontent.com/nextstrain/dengue/ingest/ingest/bin/fetch-from-genbank
    curl -fsSL --output bin/csv-to-ndjson https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/csv-to-ndjson
    chmod +x bin/*

    bin/fetch-from-genbank ~{ncbi_taxon_id} > genbank.ndjson

    if [[ ! -s genbank.ndjson ]]; then
      echo "genbank.ndjson is empty" 1>&2
      exit 1
    fi
  >>>
  output {
    File genbank_ndjson="genbank.ndjson"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task fetch_general_geolocation_rules {
  command <<<
    curl -fsSL --output general_geolocation_rules.tsv https://raw.githubusercontent.com/nextstrain/ncov-ingest/master/source-data/gisaid_geoLocationRules.tsv
  >>>
  output {
    File general_geolocation_rules="general_geolocation_rules.tsv"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task transform_field_names {
  input{
    File ndjson
    String field_map = 'collected=date submitted=date_submitted genbank_accession=accession submitting_organization=institution'
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/transform-field-names https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/transform-field-names
    chmod +x bin/*

    # (2) Transform field names
    cat ~{ndjson} \
    | ./bin/transform-field-names \
      --field-map ~{field_map} \
    > genbank_tfn.ndjson

    if [[ ! -s genbank_tfn.ndjson ]]; then
      echo "genbank_tfn.ndjson is empty" 1>&2
      exit 1
    fi
  >>>
  output {
    File out_ndjson="genbank_tfn.ndjson"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task transform_string_fields {
  input{
    File ndjson
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/transform-string-fields https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/transform-string-fields
    chmod +x bin/*

    # (2) Transform string fields
    cat ~{ndjson} \
    | ./bin/transform-string-fields --normalize \
    > genbank_tsf.ndjson

    if [[ ! -s genbank_tsf.ndjson ]]; then
      echo "genbank_tsf.ndjson is empty" 1>&2
      exit 1
    fi

  >>>
  output {
    File out_ndjson="genbank_tsf.ndjson"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task transform_strain_names {
  input{
    File ndjson
    String strain_regex='^.+\$' # Escape dollar signs in regex to bypass interpolation
    String strain_backup_fields='accession'
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/transform-strain-names https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/transform-strain-names
    chmod +x bin/*

    # (2) Transform strain names
    cat ~{ndjson} \
    | ./bin/transform-strain-names \
      --strain-regex ~{strain_regex} \
      --backup-fields ~{strain_backup_fields} \
    > genbank_tsn.ndjson

    if [[ ! -s genbank_tsn.ndjson ]]; then
      echo "genbank_tsn.ndjson is empty" 1>&2
      exit 1
    fi

  >>>
  output {
    File out_ndjson="genbank_tsn.ndjson"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task transform_date_fields {
  input{
    File ndjson
    String date_fields='date date_submitted updated' # Escape dollar signs in regex to bypass interpolation
    String expected_date_formats='%Y %Y-%m %Y-%m-%d %Y-%m-%dT%H:%M:%SZ'
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/transform-date-fields https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/transform-date-fields
    chmod +x bin/*

    # (2) Transform date fields
    cat ~{ndjson} \
    | ./bin/transform-date-fields \
      --date-fields ~{date_fields} \
      --expected-date-formats ~{expected_date_formats} \
    > genbank_tdf.ndjson

    if [[ ! -s genbank_tdf.ndjson ]]; then
      echo "genbank_tdf.ndjson is empty" 1>&2
      exit 1
    fi

  >>>
  output {
    File out_ndjson="genbank_tdf.ndjson"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task transform_genbank_location {
  input{
    File ndjson
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/transform-genbank-location https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/transform-genbank-location
    chmod +x bin/*

    # (2) Transform genbank locations
    cat ~{ndjson} \
    | ./bin/transform-genbank-location \
    > genbank_tgl.ndjson

    if [[ ! -s genbank_tgl.ndjson ]]; then
      echo "genbank_tgl.ndjson is empty" 1>&2
      exit 1
    fi

  >>>
  output {
    File out_ndjson="genbank_tgl.ndjson"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task transform_string_fields2 {
  input{
    File ndjson
    String titlecase_fields='region country division location'
    String articles='and d de del des di do en l la las le los nad of op sur the y'
    String abbreviations='USA'
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/transform-string-fields https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/transform-string-fields 
    chmod +x bin/*

    # (2) Transform string fields
    cat ~{ndjson} \
    | ./bin/transform-string-fields \
      --titlecase-fields ~{titlecase_fields} \
      --articles ~{articles} \
      --abbreviations ~{abbreviations} \
    > genbank_tsf2.ndjson

    if [[ ! -s genbank_tsf2.ndjson ]]; then
      echo "genbank_tsf2.ndjson is empty" 1>&2
      exit 1
    fi

  >>>
  output {
    File out_ndjson="genbank_tsf2.ndjson"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task transform_authors {
  input{
    File ndjson
    String authors_field='authors'
    String authors_default_value='?'
    String abbr_authors_field='abbr_authors'
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/transform-authors https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/transform-authors
    chmod +x bin/*

    # (2) Transform authors
    cat ~{ndjson} \
    | ./bin/transform-authors \
      --authors-field ~{authors_field} \
      --default-value ~{authors_default_value} \
      --abbr-authors-field ~{abbr_authors_field} \
    > genbank_ta.ndjson

    if [[ ! -s genbank_ta.ndjson ]]; then
      echo "genbank_ta.ndjson is empty" 1>&2
      exit 1
    fi

  >>>
  output {
    File out_ndjson="genbank_ta.ndjson"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task apply_geolocation_rules {
  input{
    File ndjson
    File all_geolocation_rules
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/apply-geolocation-rules https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/apply-geolocation-rules
    chmod +x bin/*

    # (2) Transform geolocations
    cat ~{ndjson} \
    | ./bin/apply-geolocation-rules \
      --geolocation-rules ~{all_geolocation_rules} \
    > genbank_agr.ndjson
    
    if [[ ! -s genbank_agr.ndjson ]]; then
      echo "genbank_agr.ndjson is empty" 1>&2
      exit 1
    fi    

  >>>
  output {
    File out_ndjson="genbank_agr.ndjson"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task merge_user_metadata {
  input{
    File ndjson
    String annotations='https://raw.githubusercontent.com/nextstrain/ebola/ingest/ingest/source-data/annotations.tsv'
    String annotations_id='accession'
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/merge-user-metadata https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/merge-user-metadata
    chmod +x bin/*
    curl -fsSL --output annotations.tsv ~{annotations}

    # (2) Transform by merging user metadata
    cat ~{ndjson} \
    | ./bin/merge-user-metadata \
      --annotations annotations.tsv \
      --id-field ~{annotations_id} \
    > genbank_mum.ndjson

    if [[ ! -s genbank_mum.ndjson ]]; then
      echo "genbank_mum.ndjson is empty" 1>&2
      exit 1
    fi
  >>>
  output {
    File out_ndjson="genbank_mum.ndjson"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task ndjson_to_tsv_and_fasta {
  input{
    File ndjson
    String metadata_columns='accession genbank_accession_rev strain strain_s viruslineage_ids date updated region country division location host date_submitted sra_accession abbr_authors reverse authors institution title publications'
    String id_field='accession'
    String sequence_field='sequence'
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/ndjson-to-tsv-and-fasta https://raw.githubusercontent.com/nextstrain/monkeypox/master/ingest/bin/ndjson-to-tsv-and-fasta
    chmod +x bin/*

    # (2) Transform ndjson to tsv and fasta
    cat ~{ndjson} \
    | ./bin/ndjson-to-tsv-and-fasta \
      --metadata-columns "~{metadata_columns}" \
      --metadata raw_metadata.tsv \
      --fasta sequences.fasta \
      --id-field ~{id_field} \
      --sequence-field ~{sequence_field}

    
    if [[ ! -s raw_metadata.tsv ]]; then
      echo "raw_metadata.tsv is empty" 1>&2
      exit 1
    fi
    if [[ ! -s sequences.fasta ]]; then
      echo "sequences.fasta is empty" 1>&2
      exit 1
    fi
  >>>
  output {
    File sequences="sequences.fasta"
    File metadata="raw_metadata.tsv"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}

task post_process_metadata {
  input{
    File metadata
  }
  command <<<
    # (1) Pull needed scripts
    mkdir bin
    curl -fsSL --output bin/post_process_metadata.py https://raw.githubusercontent.com/nextstrain/zika/2ae81db362fdeb5e832153dfaf2294fe971e638c/ingest/bin/post_process_metadata.py
    chmod +x bin/*

    # (2) Post process metadata
    ./bin/post_process_metadata.py --metadata ~{metadata} --outfile metadata.tsv

    if [[ ! -s metadata.tsv ]]; then
      echo "metadata.tsv is empty" 1>&2
      exit 1
    fi
  >>>
  output {
    File out_metadata="metadata.tsv"
  }
  runtime {
    docker: 'nextstrain/ncov-ingest:latest'
    cpu : 8
    memory: '3.5 GiB'
    disks: 'local-disk 30 HDD'
  }
}
