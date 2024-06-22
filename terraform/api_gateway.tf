resource "aws_api_gateway_rest_api" "messaging_api" {
  name = "MessagingAPI"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name        = "cognito_authorizer"
  rest_api_id = aws_api_gateway_rest_api.messaging_api.id
  type        = "COGNITO_USER_POOLS"
  provider_arns = [
    aws_cognito_user_pool.user_pool.arn
  ]
}

resource "aws_api_gateway_resource" "users" {
  rest_api_id = aws_api_gateway_rest_api.messaging_api.id
  parent_id   = aws_api_gateway_rest_api.messaging_api.root_resource_id
  path_part   = "users"
}

resource "aws_api_gateway_method" "post_user" {
  rest_api_id   = aws_api_gateway_rest_api.messaging_api.id
  resource_id   = aws_api_gateway_resource.users.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_resource" "authenticate" {
  rest_api_id = aws_api_gateway_rest_api.messaging_api.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "authenticate"
}

resource "aws_api_gateway_method" "authenticate_user" {
  rest_api_id   = aws_api_gateway_rest_api.messaging_api.id
  resource_id   = aws_api_gateway_resource.authenticate.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_resource" "messages" {
  rest_api_id = aws_api_gateway_rest_api.messaging_api.id
  parent_id   = aws_api_gateway_rest_api.messaging_api.root_resource_id
  path_part   = "messages"
}

resource "aws_api_gateway_method" "post_message" {
  rest_api_id   = aws_api_gateway_rest_api.messaging_api.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_resource" "block" {
  rest_api_id = aws_api_gateway_rest_api.messaging_api.id
  parent_id   = aws_api_gateway_resource.users.id
  path_part   = "block"
}

resource "aws_api_gateway_method" "block_user" {
  rest_api_id   = aws_api_gateway_rest_api.messaging_api.id
  resource_id   = aws_api_gateway_resource.block.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_resource" "groups" {
  rest_api_id = aws_api_gateway_rest_api.messaging_api.id
  parent_id   = aws_api_gateway_rest_api.messaging_api.root_resource_id
  path_part   = "groups"
}

resource "aws_api_gateway_method" "create_group" {
  rest_api_id   = aws_api_gateway_rest_api.messaging_api.id
  resource_id   = aws_api_gateway_resource.groups.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_method" "add_user_to_group" {
  rest_api_id   = aws_api_gateway_rest_api.messaging_api.id
  resource_id   = aws_api_gateway_resource.groups.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_method" "remove_user_from_group" {
  rest_api_id   = aws_api_gateway_rest_api.messaging_api.id
  resource_id   = aws_api_gateway_resource.groups.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_method" "send_group_message" {
  rest_api_id   = aws_api_gateway_rest_api.messaging_api.id
  resource_id   = aws_api_gateway_resource.groups.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_method" "get_messages" {
  rest_api_id   = aws_api_gateway_rest_api.messaging_api.id
  resource_id   = aws_api_gateway_resource.messages.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

resource "aws_api_gateway_integration" "post_user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.messaging_api.id
  resource_id             = aws_api_gateway_resource.users.id
  http_method             = aws_api_gateway_method.post_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.register_user.invoke_arn
}

resource "aws_api_gateway_integration" "authenticate_user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.messaging_api.id
  resource_id             = aws_api_gateway_resource.authenticate.id
  http_method             = aws_api_gateway_method.authenticate_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.authenticate_user.invoke_arn
}

resource "aws_api_gateway_integration" "post_message_integration" {
  rest_api_id             = aws_api_gateway_rest_api.messaging_api.id
  resource_id             = aws_api_gateway_resource.messages.id
  http_method             = aws_api_gateway_method.post_message.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.send_message.invoke_arn
}

resource "aws_api_gateway_integration" "block_user_integration" {
  rest_api_id             = aws_api_gateway_rest_api.messaging_api.id
  resource_id             = aws_api_gateway_resource.block.id
  http_method             = aws_api_gateway_method.block_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.block_user.invoke_arn
}

resource "aws_api_gateway_integration" "create_group_integration" {
  rest_api_id             = aws_api_gateway_rest_api.messaging_api.id
  resource_id             = aws_api_gateway_resource.groups.id
  http_method             = aws_api_gateway_method.create_group.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_group.invoke_arn
}

resource "aws_api_gateway_integration" "add_user_to_group_integration" {
  rest_api_id             = aws_api_gateway_rest_api.messaging_api.id
  resource_id             = aws_api_gateway_resource.groups.id
  http_method             = aws_api_gateway_method.add_user_to_group.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.add_user_to_group.invoke_arn
}

resource "aws_api_gateway_integration" "remove_user_from_group_integration" {
  rest_api_id             = aws_api_gateway_rest_api.messaging_api.id
  resource_id             = aws_api_gateway_resource.groups.id
  http_method             = aws_api_gateway_method.remove_user_from_group.http_method
  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.remove_user_from_group.invoke_arn
}

resource "aws_api_gateway_integration" "send_group_message_integration" {
  rest_api_id             = aws_api_gateway_rest_api.messaging_api.id
  resource_id             = aws_api_gateway_resource.groups.id
  http_method             = aws_api_gateway_method.send_group_message.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.send_group_message.invoke_arn
}

resource "aws_api_gateway_integration" "get_messages_integration" {
  rest_api_id             = aws_api_gateway_rest_api.messaging_api.id
  resource_id             = aws_api_gateway_resource.messages.id
  http_method             = aws_api_gateway_method.get_messages.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.check_messages.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.post_user,
    aws_api_gateway_method.authenticate_user,
    aws_api_gateway_method.post_message,
    aws_api_gateway_method.block_user,
    aws_api_gateway_method.create_group,
    aws_api_gateway_method.add_user_to_group,
    aws_api_gateway_method.remove_user_from_group,
    aws_api_gateway_method.send_group_message,
    aws_api_gateway_method.get_messages
  ]

  rest_api_id = aws_api_gateway_rest_api.messaging_api.id
  stage_name  = "prod"
}
