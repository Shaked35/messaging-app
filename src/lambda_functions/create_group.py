import json
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
groups_table = dynamodb.Table('Groups')

def lambda_handler(event, context):
    body = json.loads(event['body'])
    group_name = body['groupName']

    group_id = str(uuid.uuid4())
    item = {
        'GroupId': group_id,
        'GroupName': group_name,
        'CreatedAt': datetime.utcnow().isoformat()
    }

    groups_table.put_item(Item=item)

    return {
        'statusCode': 200,
        'body': json.dumps({'groupId': group_id})
    }
