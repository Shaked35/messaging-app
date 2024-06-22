import json
import boto3
import uuid
from datetime import datetime
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
group_memberships_table = dynamodb.Table('GroupMemberships')
messages_table = dynamodb.Table('Messages')


def lambda_handler(event, context):
    print("Inside lambda_handler")
    body = json.loads(event['body'])
    from_user_id = body['fromUserId']
    group_id = event['pathParameters']['groupId']
    message = body['message']

    print(f"Received fromUserId: {from_user_id}, groupId: {group_id}, message: {message}")

    response = group_memberships_table.query(
        KeyConditionExpression=Key('GroupId').eq(group_id)
    )

    print("Query response: ", response)

    message_id = str(uuid.uuid4())
    sent_at = datetime.utcnow().isoformat()

    with messages_table.batch_writer() as batch:
        for item in response['Items']:
            batch.put_item(Item={
                'MessageId': message_id,
                'UserId': item['UserId'],
                'FromUserId': from_user_id,
                'Message': message,
                'SentAt': sent_at
            })

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Message sent to group successfully'})
    }
