import json
import boto3
from botocore.exceptions import ClientError

secrets_client = boto3.client('secretsmanager', region_name='us-east-1')
cognito_client = boto3.client('cognito-idp', region_name='us-east-1')

def get_secret(secret_name):
    try:
        get_secret_value_response = secrets_client.get_secret_value(
            SecretId=secret_name
        )
        secret = get_secret_value_response['SecretString']
        return json.loads(secret)
    except ClientError as e:
        raise Exception("Error retrieving secret: " + str(e))

def lambda_handler(event, context):
    secret_name = "cognito_client_secret"
    secret = get_secret(secret_name)
    client_id = secret['client_id']

    body = json.loads(event['body'])
    username = body['username']
    password = body['password']

    try:
        response = cognito_client.initiate_auth(
            ClientId=client_id,
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': username,
                'PASSWORD': password
            }
        )
        return {
            'statusCode': 200,
            'body': json.dumps({'token': response['AuthenticationResult']['IdToken']})
        }
    except ClientError as e:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)})
        }
