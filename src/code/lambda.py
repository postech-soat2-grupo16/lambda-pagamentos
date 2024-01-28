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

def get_pagamento(body):
    payment_id = body['id']

    url_base = os.environ['URL_BASE']
    port = os.environ['PORT']
    endpoint = os.environ['ENDPOINT'].replace('id_pagamento', str(payment_id))

    url = url_base + ':' + port +  '/' + endpoint

    try:
        response = requests.get(url, headers={'Content-Type': 'application/json'})
        print('Process payment: ', response.text)

        if response.status_code > 199 and response.status_code < 300:
            return {
                'statusCode': response.status_code,
                'body': json.loads(response.text)
            }
        else:
            return {
                'statusCode': response.status_code,
                'body': json.dumps('Payment Message Error!')
            }
    except Exception as e:
        print('Exception error: ', e)
        return {
            'statusCode': 500,
            'body': json.dumps('Payment Message Exception Error!')
        }

def notify_producao(body):
    payment_response = get_pagamento(body)
    payment = payment_response['body']
    print("Notificando API PRODUCAO - Payment ID: ", payment['id'])
    print("Notificando API PRODUCAO - Pedido ID: ", payment['pedido_id'])
    
    url_base = os.environ['URL_BASE']
    port = os.environ['PORT']
    endpoint = os.environ['ENDPOINT_PRODUCAO']

    url = url_base + ':' + port +  '/' + endpoint
    print('REQUEST URL: ', url)

    try:
        response = requests.post(url, data=json.dumps(body), headers={'Content-Type': 'application/json'})
        print('Response: ', response.text)

        if response.status_code > 199 and response.status_code < 300:
            return {
                'statusCode': response.status_code,
                'body': json.dumps('Payment Message processed successfully!')
            }
        else:
            return {
                'statusCode': response.status_code,
                'body': json.dumps('Payment Message Error!')
            }
    except Exception as e:
        print('Exception error: ', e)
        return {
            'statusCode': 500,
            'body': json.dumps('Payment Message Exception Error!')
        }