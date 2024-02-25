import boto3
import json

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    print(event)

    user = event['detail']['userIdentity']['userName']
    instanceId = event['detail']['responseElements']['instanceSet']['items'][0]['instanceId']

    ec2.create_tags(
        Resources=[
            instanceId
        ],
        Tags=[
            {
                'Key': 'Owner',
                'Value': user
            },
        ]
    )
    return