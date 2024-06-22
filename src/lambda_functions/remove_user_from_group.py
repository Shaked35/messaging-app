import json
import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
group_memberships_table = dynamodb.Table('GroupMemberships')

def lambda_handler(event, context):
    body = json.loads(event['body'])
    group_id = event['pathParameters']['groupId']
    user_id = body['userId']

    key = {
        'GroupId': group_id,
        'UserId': user_id
    }

    group_memberships_table.delete_item(Key=key)

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'User removed from group successfully'})
    }
