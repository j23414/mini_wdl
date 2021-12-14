task * {
    runtime {
        conda: conda_path
        memory: mem_gb + "GB"
    }
    meta {
        author: "Nextstrain"
        email: "someone@email.com
        description: "![build_status](https://quay.io/repository/nextstrain/ncov/status) Description here"
    }
}