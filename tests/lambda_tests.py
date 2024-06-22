import json
import unittest
from unittest.mock import patch, MagicMock
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Key

from src.lambda_functions.register_user import lambda_handler as register_user_handler, get_secret
from src.lambda_functions.remove_user_from_group import lambda_handler as remove_user_from_group_handler
from src.lambda_functions.send_group_message import lambda_handler as send_group_message_handler


class TestLambdaHandler(unittest.TestCase):
    @patch('src.lambda_functions.register_user.cognito_client')
    @patch('src.lambda_functions.register_user.get_secret')
    def test_register_user_handler(self, mock_get_secret, mock_cognito_client):
        mock_get_secret.return_value = {'client_id': 'fake_client_id'}
        mock_cognito_client.sign_up = MagicMock(return_value={})

        event = {
            'body': json.dumps({'username': 'testuser', 'password': 'testpass', 'email': 'test@example.com'})
        }
        context = {}

        response = register_user_handler(event, context)

        self.assertEqual(response['statusCode'], 200)
        self.assertEqual(json.loads(response['body']), {'message': 'User registered successfully'})
        mock_cognito_client.sign_up.assert_called_once_with(
            ClientId='fake_client_id',
            Username='testuser',
            Password='testpass',
            UserAttributes=[{'Name': 'email', 'Value': 'test@example.com'}]
        )

    @patch('src.lambda_functions.register_user.cognito_client')
    @patch('src.lambda_functions.register_user.get_secret')
    def test_register_user_handler_error(self, mock_get_secret, mock_cognito_client):
        mock_get_secret.return_value = {'client_id': 'fake_client_id'}
        mock_cognito_client.sign_up = MagicMock(side_effect=ClientError({'Error': {}}, 'SignUp'))

        event = {
            'body': json.dumps({'username': 'testuser', 'password': 'testpass', 'email': 'test@example.com'})
        }
        context = {}

        response = register_user_handler(event, context)

        self.assertEqual(response['statusCode'], 400)
        self.assertIn('error', json.loads(response['body']))

    @patch('src.lambda_functions.remove_user_from_group.group_memberships_table')
    def test_remove_user_from_group_handler(self, mock_table):
        mock_table.delete_item = MagicMock()

        event = {
            'body': json.dumps({'userId': 'user123'}),
            'pathParameters': {'groupId': 'group123'}
        }
        context = {}

        response = remove_user_from_group_handler(event, context)

        self.assertEqual(response['statusCode'], 200)
        self.assertEqual(json.loads(response['body']), {'message': 'User removed from group successfully'})
        mock_table.delete_item.assert_called_once_with(Key={
            'GroupId': 'group123',
            'UserId': 'user123'
        })

    def mock_batch_writer(self):
        mock = MagicMock()
        mock.__enter__ = MagicMock(return_value=mock)
        mock.__exit__ = MagicMock(return_value=None)
        return mock

    @patch('src.lambda_functions.send_group_message.group_memberships_table')
    @patch('src.lambda_functions.send_group_message.messages_table')
    def test_send_group_message_handler(self, mock_group_table, mock_messages_table):
        mock_group_table.query = MagicMock(return_value={'Items': [{'UserId': 'user1'}, {'UserId': 'user2'}]})
        mock_messages_table.batch_writer = MagicMock(return_value=self.mock_batch_writer())

        event = {
            'body': json.dumps({'fromUserId': 'user123', 'message': 'Hello Group!'}),
            'pathParameters': {'groupId': 'group123'}
        }
        context = {}

        # Add debugging prints
        print("Before calling lambda_handler")

        response = send_group_message_handler(event, context)

        print("After calling lambda_handler")

        self.assertEqual(response['statusCode'], 200)
        self.assertEqual(json.loads(response['body']), {'message': 'Message sent to group successfully'})


if __name__ == '__main__':
    unittest.main()
