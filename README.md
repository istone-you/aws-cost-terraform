# aws-cost-terraform

> **Warning**
> `s3_region`は現在`us-east-1`しか利用できません。

AWS Cost and Usage Reportの結果をAmazon S3に保存。そのデータをAWS GlueとAmazon Athenaを使ってクエリする構成を設定するTerraformファイルです。

<img width="600" alt="CUR.drawio.png" src="CUR.drawio.png">