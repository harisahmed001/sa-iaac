
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_aws_iam_role" {
  name               = "${var.name}-codebuild_aws_iam_role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

data "aws_iam_policy_document" "codebuild_aws_iam_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_aws_iam_role_policy" {
  role   = aws_iam_role.codebuild_aws_iam_role.name
  policy = data.aws_iam_policy_document.codebuild_aws_iam_policy_document.json
}


resource "aws_codebuild_project" "codebuild_aws_codebuild_project" {
  name        = "${var.name}-project"
  description = "${var.name}-project"

  service_role = aws_iam_role.codebuild_aws_iam_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type            = "GITHUB"
    location        = var.github
    git_clone_depth = 1
  }

  logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }

    s3_logs {
      status = "DISABLED"
    }
  }
}


resource "aws_codebuild_webhook" "codebuild_aws_codebuild_webhook" {
  project_name = aws_codebuild_project.codebuild_aws_codebuild_project.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
  }
}
