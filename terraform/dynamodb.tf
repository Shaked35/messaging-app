resource "aws_dynamodb_table" "users" {
  name         = "Users"
  hash_key     = "UserId"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "UserId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "messages" {
  name         = "Messages"
  hash_key     = "MessageId"
  range_key    = "UserId"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "MessageId"
    type = "S"
  }

  attribute {
    name = "UserId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "groups" {
  name         = "Groups"
  hash_key     = "GroupId"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "GroupId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "group_memberships" {
  name         = "GroupMemberships"
  hash_key     = "GroupId"
  range_key    = "UserId"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "GroupId"
    type = "S"
  }

  attribute {
    name = "UserId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "blocked_users" {
  name         = "BlockedUsers"
  hash_key     = "UserId"
  range_key    = "BlockedUserId"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "BlockedUserId"
    type = "S"
  }
}
