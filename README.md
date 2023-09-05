# JNV_ECS_3TIER_PIPELINE

## Description
* ECS 배포 3-Tier(Source-Build-Deploy) 파이프라인을 구성하는 모듈

## Example
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

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codepipeline.jnv-ecs-3tier-pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_codestarnotifications_notification_rule.codepipeline_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarnotifications_notification_rule) | resource |
| [aws_iam_role.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.codepipeline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codebuild_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.codepipeline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.codepipeline_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.bucketownership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_public_access_block.publcaccess_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | n/a | `any` | n/a | yes |
| <a name="input_build_compute_size"></a> [build\_compute\_size](#input\_build\_compute\_size) | n/a | `string` | `"BUILD_GENERAL1_LARGE"` | no |
| <a name="input_build_image"></a> [build\_image](#input\_build\_image) | n/a | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_bulidspec_name"></a> [bulidspec\_name](#input\_bulidspec\_name) | n/a | `string` | `"buildspec.yaml"` | no |
| <a name="input_codebuild_vpc_id"></a> [codebuild\_vpc\_id](#input\_codebuild\_vpc\_id) | n/a | `string` | `"vpc-0cd28aa2e0e8c8cf7"` | no |
| <a name="input_codebuild_vpc_sg"></a> [codebuild\_vpc\_sg](#input\_codebuild\_vpc\_sg) | n/a | `list` | <pre>[<br>  "sg-083c01a8afec0d4f4"<br>]</pre> | no |
| <a name="input_codebuild_vpc_subnets"></a> [codebuild\_vpc\_subnets](#input\_codebuild\_vpc\_subnets) | n/a | `list` | <pre>[<br>  "subnet-041191089c7344807",<br>  "subnet-0b188546bc60a1e37"<br>]</pre> | no |
| <a name="input_codedeploy_app_name"></a> [codedeploy\_app\_name](#input\_codedeploy\_app\_name) | n/a | `any` | n/a | yes |
| <a name="input_codedeploy_deploymentgroup_name"></a> [codedeploy\_deploymentgroup\_name](#input\_codedeploy\_deploymentgroup\_name) | n/a | `any` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | n/a | `string` | `"szs-apne2-ecs-dev"` | no |
| <a name="input_ecs_deploy_taskdef_filename"></a> [ecs\_deploy\_taskdef\_filename](#input\_ecs\_deploy\_taskdef\_filename) | n/a | `string` | `"taskdef.json"` | no |
| <a name="input_ecs_is_bluegreen"></a> [ecs\_is\_bluegreen](#input\_ecs\_is\_bluegreen) | n/a | `bool` | `false` | no |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | n/a | `any` | n/a | yes |
| <a name="input_github_connection_arn"></a> [github\_connection\_arn](#input\_github\_connection\_arn) | n/a | `any` | n/a | yes |
| <a name="input_github_fullrepository_id"></a> [github\_fullrepository\_id](#input\_github\_fullrepository\_id) | n/a | `any` | n/a | yes |
| <a name="input_jnv_environment"></a> [jnv\_environment](#input\_jnv\_environment) | n/a | `string` | `"dev"` | no |
| <a name="input_jnv_project"></a> [jnv\_project](#input\_jnv\_project) | n/a | `string` | `"szs"` | no |
| <a name="input_jnv_region"></a> [jnv\_region](#input\_jnv\_region) | n/a | `string` | `"apne2"` | no |
| <a name="input_need_approval"></a> [need\_approval](#input\_need\_approval) | n/a | `bool` | `false` | no |
| <a name="input_pipeline_branch"></a> [pipeline\_branch](#input\_pipeline\_branch) | n/a | `any` | n/a | yes |
| <a name="input_pipeline_chatbot_arn"></a> [pipeline\_chatbot\_arn](#input\_pipeline\_chatbot\_arn) | n/a | `string` | `"arn:aws:chatbot::185236431346:chat-configuration/slack-channel/aws-pipeline"` | no |
| <a name="input_secret_arn"></a> [secret\_arn](#input\_secret\_arn) | n/a | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->