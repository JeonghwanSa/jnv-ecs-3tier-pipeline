variable "application_name" {}
variable "jnv_project" {
  default = "szs"
}
variable "jnv_region" {
  default = "apne2"
}
variable "jnv_environment" {
  default = "dev"
}
variable "pipeline_branch" {}
variable "build_compute_size" {
  default = "BUILD_GENERAL1_LARGE"
}
variable "build_image" {
  default = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}
variable "bulidspec_name" {
  default = "buildspec.yaml"
}
variable "codebuild_vpc_id" {
  default = "vpc-0cd28aa2e0e8c8cf7"
}
variable "codebuild_vpc_subnets" {
  default = ["subnet-041191089c7344807", "subnet-0b188546bc60a1e37"]
}
variable "codebuild_vpc_sg" {
  default = ["sg-083c01a8afec0d4f4"]
}
variable "need_approval" {
  type    = bool
  default = false
}
variable "ecs_cluster_name" {
  default = "szs-apne2-ecs-dev"
}
variable "ecs_service_name" {}
variable "ecs_deploy_taskdef_filename" {
  default = "taskdef.json"
}
variable "ecs_is_bluegreen" {
  type    = bool
  default = false
}
variable "codedeploy_app_name" {
}
variable "codedeploy_deploymentgroup_name" {
}
variable "pipeline_chatbot_arn" {
  default = "arn:aws:chatbot::185236431346:chat-configuration/slack-channel/aws-pipeline"
}
variable "secret_arn" {}
variable "github_connection_arn" {}
variable "github_fullrepository_id" {}
