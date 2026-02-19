from prophecy_pipeline_sdk.graph import *
from prophecy_pipeline_sdk.properties import *
Schedules = [SensorSchedule(
               Name = "run on new file arrival and move to archive ",
               sftp_1_1_EGiyN0zJ9Pw4LJ207ohG6 = {
                 "connector": "sftp_1",
                 "properties": {
                   "filePath": "/prophecy-sftp/demo_files/*.csv",
                   "pollSensor": {
                     "expBackOff": True,
                     "mode": "reschedule",
                     "pokeInterval": 0,
                     "baseSensor": {"timeout" : 0}
                   }
                 },
                 "sequenceId": 1
               }
             )]
args = PipelineArgs(
    label = "trigger",
    version = 1,
    auto_layout = False,
    params = Parameters(sftp_processed_path = "'/prophecy-sftp/demo_files_processed/*'"),
    schedules = Schedules
)

with Pipeline(args) as pipeline:
    accounts_updated_csv_0 = Process(
        name = "accounts_updated_csv_0",
        properties = SFTPSource(
          compression = SFTPSource.Compression(kind = "uncompressed"),
          connector = "sftp_1",
          format = SFTPSource.CsvReadFormat(schema = "external_sources/trigger/accounts_updated_csv_0.yml"),
          properties = SFTPSource.SFTPSourceInternal(filePath = "/prophecy-sftp/demo_files/accounts_updated.csv")
        ),
        input_ports = None
    )
    account_engagement_campaigns_csv = Process(
        name = "account_engagement_campaigns_csv",
        properties = SFTPTarget(
          compression = SFTPTarget.Compression(kind = "uncompressed"),
          properties = SFTPTarget.SFTPTargetInternal(
            filePath = {
              "type": "concat_operation",
              "properties": {
                "elements": [{
                                "type": "config",
                                "properties": {"configType" : "pipeline", "name" : "sftp_processed_path"}
                              },
                              {"type" : "literal", "properties" : {"value" : "/accounts_updated_filtered.csv"}}]
              }
            }
          ),
          connector = "sftp_1"
        ),
        output_ports = None
    )
    trigger__reformat_1 = Process(
        name = "trigger__Reformat_1",
        properties = ModelTransform(modelName = "trigger__Reformat_1")
    )
    accounts_updated_csv_0 >> trigger__reformat_1
    trigger__reformat_1 >> account_engagement_campaigns_csv
