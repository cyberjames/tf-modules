data "aws_iam_policy_document" "ecs_execution" {
    version = "2012-10-17"

    # Baseline
    statement {
        actions = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        effect = "Allow"
        resources = [
            "*"
        ]
    }

    ## Extend with iam permission statements
    dynamic "statement" {
        for_each = var.ecs_execution_other_iam_statements
        content {
            actions   = statement.value["actions"]
            effect    = statement.value["effect"]
            resources = statement.value["resources"]
        }
    }
}

resource "aws_iam_policy" "ecs_execution" {
  count       = var.create_ecs_execution_role == true ? 1 : 0
  name        = "ecs-execution-role-policy"
  description = "Custom Policy for ECS Execution"
  policy      = data.aws_iam_policy_document.ecs_execution.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type        = "Service"
            identifiers = [
                "ecs-tasks.amazonaws.com"
            ]
        }
    }
}

resource "aws_iam_role" "ecs_task_role" {
  count                = var.create_ecs_task_role == true ? 1 : 0
  name                 = "Policy-Ecs-Task-Role"
  assume_role_policy   = data.aws_iam_policy_document.ecs_task_assume_role.json
  description          = "IAM Role with permissions for ECS tasks"
}

resource "aws_iam_role" "ecs_execution_role" {
  count                = var.create_ecs_execution_role == true ? 1 : 0
  name                 = "Policy-Ecs-Execution-Role"
  assume_role_policy   = data.aws_iam_policy_document.ecs_task_assume_role.json
  description          = "IAM Role with permissions for ECS Execution of tasks"
}

resource "aws_iam_policy_attachment" "attachment" {
    count      = var.create_ecs_execution_role == true ? 1 : 0
    name       = "Policy-ECS-Execution-Role-Policy"
    policy_arn = aws_iam_policy.ecs_execution[0].arn
    roles      = [aws_iam_role.ecs_execution_role[0].name]
}
