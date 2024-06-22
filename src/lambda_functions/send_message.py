import json
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
messages_table = dynamodb.Table('Messages')
blocked_users_table = dynamodb.Table('BlockedUsers')


def lambda_handler(event, context):
    body = json.loads(event['body'])
    from_user_id = body['fromUserId']
    to_user_id = body['toUserId']
    message = body['message']

    block_response = blocked_users_table.get_item(
        Key={'UserId': to_user_id, 'BlockedUserId': from_user_id}
    )

    if 'Item' in block_response:
        return {
            'statusCode': 403,
            'body': json.dumps({'error': 'You are blocked from sending messages to this user.'})
        }

    message_id = str(uuid.uuid4())
    item = {
        'MessageId': message_id,
        'UserId': to_user_id,
        'FromUserId': from_user_id,
        'Message': message,
        'SentAt': datetime.utcnow().isoformat()
    }

    messages_table.put_item(Item=item)

    return {
        'statusCode': 200,
        'body': json.dumps({'messageId': message_id})
    }
