import json
import requests
import os

def main(event, context):
    for record in event['Records']:
        message_body = json.loads(record['body'])
        process_sqs_message(message_body)
        return notify_producao(message_body)

def process_sqs_message(message_body):
    print("Processing SQS message:")
    print("Body:", message_body)

def notify_producao(body):
    payment_id = body['id']
    print("Notificando API PRODUCAO - Payment ID: ", payment_id)

    url_base = os.environ['URL_BASE']
    port = os.environ['PORT']
    endpoint = os.environ['ENDPOINT']

    url = url_base + ':' + port +  '/' + endpoint
    print('REQUEST URL: ', url)

    try:
        response = requests.get(url, data=json.dumps(body), headers={'Content-Type': 'application/json'})
        print('Response: ', response.json())

        if response.status_code == 201:
            return {
                'statusCode': 200,
                'body': json.dumps('Payment {payment_id} Message processed successfully!')
            }
        else:
            return {
                'statusCode': response.status_code,
                'body': json.dumps('Payment {payment_id} Message Error!')
            }
    except Exception as e:
        print('Exception error: ', e)
        return {
            'statusCode': 500,
            'body': json.dumps('Payment {payment_id} Message Exception Error!')
        }