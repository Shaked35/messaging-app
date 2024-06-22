import json

import pytest
from moto import mock_aws

import boto3

import os

os.environ['AWS_ACCESS_KEY_ID'] = 'testing'
os.environ['AWS_SECRET_ACCESS_KEY'] = 'testing'
os.environ['AWS_SECURITY_TOKEN'] = 'testing'
os.environ['AWS_SESSION_TOKEN'] = 'testing'
os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'

@mock_aws(config={
    "batch": {"use_docker": True},
    "lambda": {"use_docker": True},
    "core": {
        "mock_credentials": True,
        "passthrough": {
            "urls": ["s3.amazonaws.com/bucket*"],
            "services": ["dynamodb"]
        },
        "reset_boto3_session": True,
    },
    "iam": {"load_aws_managed_policies": False},
    "stepfunctions": {"execute_state_machine": True},
})
@pytest.fixture(scope='function')
def dynamodb():
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    # Setup tables
    users_table = dynamodb.create_table(
        TableName='Users',
        KeySchema=[{'AttributeName': 'UserId', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'UserId', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    messages_table = dynamodb.create_table(
        TableName='Messages',
        KeySchema=[{'AttributeName': 'MessageId', 'KeyType': 'HASH'}, {'AttributeName': 'UserId', 'KeyType': 'RANGE'}],
        AttributeDefinitions=[{'AttributeName': 'MessageId', 'AttributeType': 'S'},
                              {'AttributeName': 'UserId', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    blocked_users_table = dynamodb.create_table(
        TableName='BlockedUsers',
        KeySchema=[{'AttributeName': 'UserId', 'KeyType': 'HASH'},
                   {'AttributeName': 'BlockedUserId', 'KeyType': 'RANGE'}],
        AttributeDefinitions=[{'AttributeName': 'UserId', 'AttributeType': 'S'},
                              {'AttributeName': 'BlockedUserId', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    groups_table = dynamodb.create_table(
        TableName='Groups',
        KeySchema=[{'AttributeName': 'GroupId', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'GroupId', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    group_memberships_table = dynamodb.create_table(
        TableName='GroupMemberships',
        KeySchema=[{'AttributeName': 'GroupId', 'KeyType': 'HASH'}, {'AttributeName': 'UserId', 'KeyType': 'RANGE'}],
        AttributeDefinitions=[{'AttributeName': 'GroupId', 'AttributeType': 'S'},
                              {'AttributeName': 'UserId', 'AttributeType': 'S'}],
        BillingMode='PAY_PER_REQUEST'
    )
    yield


@mock_aws
@pytest.fixture(scope='function')
def secretsmanager():
    secrets_client = boto3.client('secretsmanager', region_name='us-east-1')
    secret_name = "cognito_client_secret"
    secret_value = json.dumps({'client_id': 'test_client_id'})
    secrets_client.create_secret(Name=secret_name, SecretString=secret_value)
    yield
