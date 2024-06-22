# Messaging Backend API

This project is a cloud-based messaging backend API built using AWS services such as API Gateway, Lambda, DynamoDB,
Cognito, and Secrets Manager. The backend supports user registration, authentication, sending messages, blocking users,
creating groups, adding/removing users from groups, and checking messages.

## Table of Contents

- [Architecture](#architecture)
- [Flow and Architecture of the Messaging Backend API](#flow-and-architecture-of-the-messaging-backend-api)
  - [User Journey](#user-journey)
  - [Security Enhancements](#security-enhancements)
  - [Implementation Details](#implementation-details)
- [Setup and Deployment](#setup-and-deployment)
- [Testing](#testing)
- [Security](#security)
- [License](#license)

## Architecture

The architecture consists of the following components:

1. **API Gateway**: Manages API endpoints and integrates with Lambda functions.
2. **Lambda Functions**: Handles the business logic for user registration, authentication, messaging, and group
   management.
3. **DynamoDB**: Stores user data, messages, groups, and blocked users.
4. **Cognito**: Manages user authentication and authorization.
5. **Secrets Manager**: Securely stores and retrieves sensitive information such as Cognito client ID.

## Flow and Architecture of the Messaging Backend API

### User Journey

1. User Registration:
    1. Client sends a registration request to the API Gateway.
    2. API Gateway routes the request to the register_user Lambda function.
    3. The register_user Lambda function:
        1. Uses Cognito to create a new user and retrieves the user ID.
        2. Stores user data in the DynamoDB Users table.
        3. Returns a success message to the client.

2. User Authentication:
    1. Client sends an authentication request to the API Gateway.
    2. API Gateway routes the request to the authenticate_user Lambda function.
    3. The authenticate_user Lambda function:
        1. Uses Cognito to authenticate the user.
        2. Retrieves a token from Cognito.
        3. Returns the token to the client.

3. Send Message:
    1. Client sends a message request to the API Gateway.
    2. API Gateway routes the request to the send_message Lambda function.
    3. The send_message Lambda function:
        1. Checks the DynamoDB BlockedUsers table to ensure the recipient is not blocking the sender.
        2. Stores the message in the DynamoDB Messages table.
        3. Returns a success message to the client.

4. Block User:
    1. Client sends a block user request to the API Gateway.
    2. API Gateway routes the request to the block_user Lambda function.
    3. The block_user Lambda function:
        1. Updates the DynamoDB BlockedUsers table to block the specified user.
        2. Returns a success message to the client.

5. Create Group:
    1. Client sends a create group request to the API Gateway.
    2. API Gateway routes the request to the create_group Lambda function.
    3. The create_group Lambda function:
        1. Creates a new group in the DynamoDB Groups table.
        2. Returns the group ID to the client.
6. Add User to Group:
    1. Client sends an add user to group request to the API Gateway.
    2. API Gateway routes the request to the add_user_to_group Lambda function.
    3. The add_user_to_group Lambda function:
        1. Updates the DynamoDB GroupMemberships table to add the user to the group.
        2. Returns a success message to the client.
7. Remove User from Group:
    1. Client sends a remove user from group request to the API Gateway.
    2. API Gateway routes the request to the remove_user_from_group Lambda function.
    3. The remove_user_from_group Lambda function:
        1. Updates the DynamoDB GroupMemberships table to remove the user from the group.
        2. Returns a success message to the client.

8. Send Group Message:
    1. Client sends a group message request to the API Gateway.
    2. API Gateway routes the request to the send_group_message Lambda function.
    3. The send_group_message Lambda function:
        1. Retrieves group members from the DynamoDB GroupMemberships table.
        2. Stores the message in the DynamoDB Messages table.
        3. Returns a success message to the client.
9. Check Messages:

    1. Client sends a check messages request to the API Gateway.
    2. API Gateway routes the request to the check_messages Lambda function.
    3. The check_messages Lambda function:
        1. Retrieves messages for the user from the DynamoDB Messages table.
        2. Returns the messages to the client.

### Security Enhancements
User Authentication and Authorization:

Utilized AWS Cognito for managing user authentication and authorization.
Users must authenticate using their credentials to obtain a JWT token.
JWT token is required for accessing protected endpoints.
Secrets Management:

Used AWS Secrets Manager to securely store and manage sensitive information like Cognito client IDs.
Lambda functions retrieve secrets from Secrets Manager to avoid hardcoding sensitive information.
Environment Variables:

Used environment variables to store AWS credentials and other sensitive information, ensuring they are not hardcoded in
the codebase.
Access Control:

Implemented access control checks in the send_message Lambda function to verify if a user is blocked by the recipient.
Implemented role-based access control in group-related operations to ensure only authorized users can perform specific
actions.

### Implementation Details

**Lambda Functions**

register_user:

Handles user registration by interacting with AWS Cognito and DynamoDB.
authenticate_user:

Handles user authentication by interacting with AWS Cognito.
send_message:

Handles sending messages between users.
Checks if the recipient has blocked the sender before storing the message in DynamoDB.
block_user:

Handles blocking a user by updating the DynamoDB BlockedUsers table.
create_group:

Handles creating a new group in the DynamoDB Groups table.
add_user_to_group:

Handles adding a user to a group by updating the DynamoDB GroupMemberships table.
remove_user_from_group:

Handles removing a user from a group by updating the DynamoDB GroupMemberships table.
send_group_message:

Handles sending messages to a group by storing the message in the DynamoDB Messages table.
check_messages:

Handles checking messages for a user by retrieving messages from the DynamoDB Messages table.
**DynamoDB Tables**

Users table:

Stores user data.
Messages table:

Stores messages sent between users and within groups.
BlockedUsers table:

Stores information about users who have blocked other users.
Groups table:

Stores group information.
GroupMemberships table:

Stores information about group memberships.
**API Gateway**
Manages all API endpoints and routes requests to the appropriate Lambda functions.
Ensures that only authenticated and authorized requests are processed.
This architecture provides a scalable, secure, and efficient messaging backend using AWS services, ensuring that user
data is managed securely and access control is enforced appropriately.

## Setup and Deployment

### Prerequisites

- AWS account
- AWS CLI installed and configured
- Terraform installed
- Python 3.9 installed

### Steps

1. **Clone the repository**:
   ```sh
   git clone https://github.com/your-repo/messaging-backend.git
   cd messaging-backend
2. Install dependencies and package Lambda functions:

    ```sh
    cd lambda
    pip install -r requirements.txt -t .
    zip -r ../lambda.zip .
    cd ..
    ```

3. Initialize and apply Terraform configuration:
    1. You must install Terraform and configure your AWS credentials first.

    ```sh
    cd./terraform 
    terraform init
    terraform -chdir=terraform apply -auto-approve
    ```

4. *Deployment script:*

Alternatively, you can use the deployment script:

    ```sh
    ./deploy.sh
    ```

## Testing
Tests are included to ensure the functionality of the Lambda functions. Tests are located in the tests directory and use
pytest along with moto to mock AWS services.

Running Tests
Install test dependencies:

```sh
pip install -r lambda/requirements.txt
```

Run tests:

```sh
pytest tests/
```

## Security

- Cognito: Manages user authentication and authorization.
- Secrets Manager: Securely stores and retrieves sensitive information such as Cognito client ID.

## License
This project is licensed under the MIT License.
# messaging-app
