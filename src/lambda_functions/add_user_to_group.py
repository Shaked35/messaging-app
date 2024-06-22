import json
import boto3

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
group_memberships_table = dynamodb.Table('GroupMemberships')


def lambda_handler(event, context):
    body = json.loads(event['body'])
    group_id = event['pathParameters']['groupId']
    user_id = body['userId']

    item = {
        'GroupId': group_id,
        'UserId': user_id
    }

    group_memberships_table.put_item(Item=item)

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'User added to group successfully'})
    }
