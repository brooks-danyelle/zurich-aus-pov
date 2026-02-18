from prophecy_pipeline_sdk.graph import *
from prophecy_pipeline_sdk.properties import *
args = PipelineArgs(label = "gl_reconciliation", version = 1, auto_layout = False)

with Pipeline(args) as pipeline:
    gl_reconciliation__joined_data = Process(
        name = "gl_reconciliation__joined_data",
        properties = ModelTransform(modelName = "gl_reconciliation__joined_data"),
        input_ports = ["in_0", "in_1", "in_2", "in_3"]
    )
    gl_reconciliation__validation_results = Process(
        name = "gl_reconciliation__validation_results",
        properties = ModelTransform(modelName = "gl_reconciliation__validation_results"),
        input_ports = ["in_0", "in_1"]
    )
    gl_reconciliation__financial_transactions_ledger = Process(
        name = "gl_reconciliation__financial_transactions_ledger",
        properties = ModelTransform(modelName = "gl_reconciliation__financial_transactions_ledger")
    )
    (
        gl_reconciliation__joined_data._out(0)
        >> [gl_reconciliation__validation_results._in(0), gl_reconciliation__validation_results._in(1),
              gl_reconciliation__financial_transactions_ledger._in(0)]
    )
