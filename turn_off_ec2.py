import json
import boto3
from datetime import datetime, time
import pytz
zone =pytz.timezone('Asia/Ho_Chi_Minh')
timetest=datetime.now(zone)
print(timetest.strftime("%H,%M"))
ec2 = boto3.resource('ec2', region_name='ap-northeast-1')

def start_stopped_instances(ec2):
    stopped_instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['stopped']}, {'Name' : 'tag:env', 'Values' : ['test']}])
    for instance in stopped_instances:
        id=instance.id
        ec2.instances.filter(InstanceIds=[id]).start()
    print("All Environment:Dev Instances are now started.")
def stop_instances(ec2):
    running_instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    for instance in running_instances:
        id=instance.id
        ec2.instances.filter(InstanceIds=[id]).stop()

if (timetest.strftime("%H,%M")== "08,00"):
    start_stopped_instances(ec2)
if (timetest.strftime("%H,%M")== "17,35"):
    stop_instances(ec2)   
    
    


    
    