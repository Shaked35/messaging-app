import json
import boto3

dynamodb = boto3.resource('dynamodb')
messages_table = dynamodb.Table('Messages')


def lambda_handler(event, context):
    user_id = event['pathParameters']['userId']

    response = messages_table.query(
        IndexName='UserId-index',
        KeyConditionExpression=dynamodb.conditions.Key('UserId').eq(user_id)
    )

    return {
        'statusCode': 200,
        'body': json.dumps(response['Items'])
    }
