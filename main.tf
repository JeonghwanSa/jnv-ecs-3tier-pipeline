data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = join("-", ["${var.jnv_project}", "${var.jnv_region}", lower("${var.application_name}"), "pipeline-artifact", "${var.jnv_environment}"])
}

resource "aws_s3_bucket_ownership_controls" "bucketownership" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "publicaccess_block" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "codepipeline_role" {
  name = join("-", ["${var.jnv_project}", "${var.jnv_region}", "${var.application_name}", "pipeline-service-role", "${var.jnv_environment}"])

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ],
        Resource = [
          "${aws_s3_bucket.codepipeline_bucket.arn}",
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetDeploymentGroup",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:StopDeployment",
          "codedeploy:ContinueDeployment",
        ],
        Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:DescribeImages"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecs:*"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : [
          "*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "codestar-connections:UseConnection"
        ],
        Resource = [
          "${var.github_connection_arn}"
        ]
      }
    ]
  })
}

resource "aws_codepipeline" "jnv-ecs-3tier-pipeline" {
  name     = join("-", ["${var.jnv_project}", "${var.jnv_region}", "${var.application_name}", "pipeline", "${var.jnv_environment}"])
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }
  stage {
    name = "Source"
    action {
      name             = "FetchCode"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      run_order        = 1
      output_artifacts = ["SourceArtifact"]
      configuration = {
        ConnectionArn    = var.github_connection_arn
        FullRepositoryId = var.github_fullrepository_id
        BranchName       = var.pipeline_branch
      }
    }
  }
  stage {
    name = "Build"
    action {
      category = "Build"
      configuration = {
        "ProjectName" = "${aws_codebuild_project.codebuild_project.name}"
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      output_artifacts = [
        "BuildArtifact"
      ]
      name      = "Build"
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }
  dynamic "stage" {
    for_each = var.need_approval == true ? [1] : []
    content {
      name = "Approval"
      action {
        name     = "Approval"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
      }
    }
  }
  dynamic "stage" {
    for_each = var.ecs_is_bluegreen == false ? [1] : []

    content {
      name = "Deploy"
      action {
        category = "Deploy"
        configuration = {
          ClusterName = var.ecs_cluster_name
          FileName    = var.ecs_deploy_taskdef_filename
          ServiceName = var.ecs_service_name
        }
        input_artifacts  = ["BuildArtifact"]
        name             = "Deploy"
        namespace        = "DeployVariables"
        output_artifacts = []
        owner            = "AWS"
        provider         = "ECS"
        region           = "ap-northeast-2"
        role_arn         = null
        run_order        = 1
        version          = "1"
      }
    }
  }
  dynamic "stage" {
    for_each = var.ecs_is_bluegreen == true ? [1] : []

    content {
      name = "Deploy"
      action {
        category = "Deploy"
        configuration = {
          AppSpecTemplateArtifact        = "BuildArtifact"
          AppSpecTemplatePath            = "appspec.yml"
          ApplicationName                = var.codedeploy_app_name
          DeploymentGroupName            = var.codedeploy_deploymentgroup_name
          TaskDefinitionTemplateArtifact = "BuildArtifact"
          TaskDefinitionTemplatePath     = var.ecs_deploy_taskdef_filename
        }
        input_artifacts  = ["BuildArtifact"]
        name             = "Deploy"
        namespace        = "DeployVariables"
        output_artifacts = []
        owner            = "AWS"
        provider         = "CodeDeployToECS"
        region           = "ap-northeast-2"
        role_arn         = null
        run_order        = 1
        version          = "1"
      }
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name = join("-", ["${var.jnv_project}", "${var.jnv_region}", "${var.application_name}", "cb-service-role", "${var.jnv_environment}"])

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "codebuild_policy"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudformation:*",
          "ecs:*",
          "ecr:*",
          "ec2:*",
          "lambda:*",
          "apigateway:*",
          "iam:PassRole",
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.codepipeline_bucket.arn}",
          "${aws_s3_bucket.codepipeline_bucket.arn}/*"
        ],
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
      },
      {
        Effect = "Allow",
        Resource = [
          "arn:aws:logs:ap-northeast-2:${local.account_id}:log-group:/aws/codebuild/*",
          "arn:aws:logs:ap-northeast-2:${local.account_id}:log-group:/aws/codebuild/*:*",
        ],
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect = "Allow",
        Resource = [
          "${var.secret_arn}",
          "arn:aws:secretsmanager:ap-northeast-2:${local.account_id}:secret:/CodeBuild/nexus/reader-*"
        ],
        Action = [
          "secretsmanager:GetSecretValue"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParametersByPath",
          "ssm:GetParameters"
        ],
        "Resource" : [
          "arn:aws:ssm:ap-northeast-2:${local.account_id}:parameter/CodeBuild/*",
        ]
      }
    ]
  })
}

resource "aws_codebuild_project" "codebuild_project" {
  badge_enabled  = false
  build_timeout  = 60
  name           = join("-", ["${var.jnv_project}", "${var.jnv_region}", "${var.application_name}", "cb", "${var.jnv_environment}"])
  queued_timeout = 480
  service_role   = aws_iam_role.codebuild.arn
  artifacts {
    encryption_disabled    = false
    name                   = var.application_name
    override_artifact_name = true
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = var.build_compute_size
    image                       = var.build_image
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false
    type                        = "LINUX_CONTAINER"

    environment_variable {
      name  = "CODEPIPELINE_BUCKET"
      value = aws_s3_bucket.codepipeline_bucket.id
    }

    dynamic "environment_variable" {
      for_each = var.codebuild_environment_variables
      content {
        type  = environment_variable.value["type"]
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
    buildspec           = var.buildspec_name
  }

  dynamic "vpc_config" {
    for_each = var.codebuild_vpc_id != "" ? [1] : []
    content {
      security_group_ids = var.codebuild_vpc_sg
      subnets            = var.codebuild_vpc_subnets
      vpc_id             = var.codebuild_vpc_id
    }
  }

  # lifecycle {
  #   ignore_changes = [
  #     environment[0].environment_variable
  #   ]
  # }
}

resource "aws_codestarnotifications_notification_rule" "codepipeline_notification" {
  detail_type = "FULL"
  event_type_ids = [
    "codepipeline-pipeline-action-execution-canceled",
    "codepipeline-pipeline-action-execution-failed",
    "codepipeline-pipeline-action-execution-started",
    "codepipeline-pipeline-action-execution-succeeded"
  ]
  name     = join("-", ["${var.jnv_project}", "${var.jnv_region}", "${var.application_name}", "ecs-pipeline-alarm", "${var.jnv_environment}"])
  resource = aws_codepipeline.jnv-ecs-3tier-pipeline.arn
  status   = "ENABLED"
  tags     = {}
  tags_all = {}
  target {
    address = var.pipeline_chatbot_arn
    type    = "AWSChatbotSlack"
  }
}
