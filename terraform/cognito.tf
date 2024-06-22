resource "aws_cognito_user_pool" "user_pool" {
  name = "messaging_user_pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "messaging_user_pool_client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_secretsmanager_secret" "cognito_client_secret" {
  name = "cognito_client_secret"
}

resource "aws_secretsmanager_secret_version" "cognito_client_secret_version" {
  secret_id     = aws_secretsmanager_secret.cognito_client_secret.id
  secret_string = jsonencode({
    client_id = aws_cognito_user_pool_client.user_pool_client.id
  })
}
