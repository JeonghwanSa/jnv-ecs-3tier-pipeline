# JNV_ECS_3TIER_PIPELINE

## description
* ECS 배포 3-Tier(Source-Build-Deploy) 파이프라인을 구성하는 모듈

## example
```
module "jnv_ecs_3tier_pipeline" {
  source                   = "git::https://github.com/JeonghwanSa/jnv-ecs-3tier-pipeline.git"
  application_name         = "jobis-example"
  pipeline_branch          = "dev"
  build_image              = "1234456789000.dkr.ecr.ap-northeast-2.amazonaws.com/buildimage:latest"
  bulidspec_name           = "buildspec.yml"
  codebuild_vpc_id         = "vpc-1234abcd5678efghi"
  codebuild_vpc_subnets    = ["subnet-1234abcd5678efghi", "subnet-1234abcd5678efghi"]
  codebuild_vpc_sg         = ["sg-1234abcd5678efghi"]
  ecs_cluster_name         = "cluster_name"
  ecs_service_name         = "service_name"
  github_connection_arn    = "arn:aws:codestar-connections:ap-northeast-2:111122223333:connection/1234abcd-5678-efgh-9000-ijkl0000mnop"
  github_fullrepository_id = "jobisnvillains/szs-jobis-example-tf"
}
```