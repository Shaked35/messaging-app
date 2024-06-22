data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/lambda_functions"
  output_path = "${path.module}/../src/lambda_functions.zip"
}

resource "aws_lambda_function" "register_user" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "RegisterUser"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "register_user.lambda_handler"
  runtime          = "python3.9"

  environment {
    variables = {
      COGNITO_CLIENT_SECRET_NAME = aws_secretsmanager_secret.cognito_client_secret.name
    }
  }
}

resource "aws_lambda_function" "authenticate_user" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "AuthenticateUser"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "authenticate_user.lambda_handler"
  runtime          = "python3.9"

  environment {
    variables = {
      COGNITO_CLIENT_SECRET_NAME = aws_secretsmanager_secret.cognito_client_secret.name
    }
  }
}

resource "aws_lambda_function" "send_message" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "SendMessage"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "send_message.lambda_handler"
  runtime          = "python3.9"

  environment {
    variables = {
      MESSAGES_TABLE      = aws_dynamodb_table.messages.name,
      BLOCKED_USERS_TABLE = aws_dynamodb_table.blocked_users.name
    }
  }
}

resource "aws_lambda_function" "block_user" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "BlockUser"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "block_user.lambda_handler"
  runtime          = "python3.9"

  environment {
    variables = {
      BLOCKED_USERS_TABLE = aws_dynamodb_table.blocked_users.name
    }
  }
}

resource "aws_lambda_function" "create_group" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "CreateGroup"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "create_group.lambda_handler"
  runtime          = "python3.9"

  environment {
    variables = {
      GROUPS_TABLE = aws_dynamodb_table.groups.name
    }
  }
}

resource "aws_lambda_function" "add_user_to_group" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "AddUserToGroup"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "add_user_to_group.lambda_handler"
  runtime          = "python3.9"

  environment {
    variables = {
      GROUP_MEMBERSHIPS_TABLE = aws_dynamodb_table.group_memberships.name
    }
  }
}

resource "aws_lambda_function" "remove_user_from_group" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "RemoveUserFromGroup"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "remove_user_from_group.lambda_handler"
  runtime          = "python3.9"

  environment {
    variables = {
      GROUP_MEMBERSHIPS_TABLE = aws_dynamodb_table.group_memberships.name
    }
  }
}

resource "aws_lambda_function" "send_group_message" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "SendGroupMessage"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "send_group_message.lambda_handler"
  runtime          = "python3.9"

  environment {
    variables = {
      GROUP_MEMBERSHIPS_TABLE = aws_dynamodb_table.group_memberships.name,
      MESSAGES_TABLE          = aws_dynamodb_table.messages.name
    }
  }
}

resource "aws_lambda_function" "check_messages" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "CheckMessages"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "check_messages.lambda_handler"
  runtime          = "python3.9"

  environment {
    variables = {
      MESSAGES_TABLE = aws_dynamodb_table.messages.name
    }
  }
}
