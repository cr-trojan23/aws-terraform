import json

def handler(event, context):
    print("Hello World")
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }