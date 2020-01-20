import json

def lambda_handler(event, content):
    print('Received event: %s' % json.dumps(event))