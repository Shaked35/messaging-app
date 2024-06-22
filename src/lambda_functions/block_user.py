import json
import boto3

dynamodb = boto3.resource('dynamodb')
blocked_users_table = dynamodb.Table('BlockedUsers')

def lambda_handler(event, context):
    body = json.loads(event['body'])
    user_id = body['userId']
    blocked_user_id = body['blockedUserId']

    item = {
        'UserId': user_id,
        'BlockedUserId': blocked_user_id
    }

    blocked_users_table.put_item(Item=item)

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'User blocked successfully'})
    }
