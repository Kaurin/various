#!/bin/bash

set -e

SSH_KEYPATH="~/.ssh/milos-london-aws.pem"
SG_ID="sg-a044f2c9"
AWS_SSH_KEYNAME="milos-london-aws"
export AWS_DEFAULT_REGION="eu-west-2"
SSH_TIMEOUT=5


cleanup() {
  echo "Cleanup: Starting cleanup"
  if  [ "$AWS_INSTANCEID" == "" ] ; then
    echo "Cleanup: nothing to do. Exiting."
    exit 0
  fi
  echo "Cleanup: Terminating the instance"
  aws ec2 terminate-instances --instance-ids "$AWS_INSTANCEID"
  exit 0
}
trap cleanup 1 SIGINT SIGTERM

AWS_MINIMAL_AMI=$(
  aws ssm get-parameter \
    --name /aws/service/ami-amazon-linux-latest/amzn-ami-minimal-hvm-x86_64-ebs \
    --query 'Parameter.Value' \
    --output text
)

echo "Latest Amazon Linux AMI: $AWS_MINIMAL_AMI ..."

AWS_INSTANCEID=$(
  aws ec2 run-instances \
        --image-id "$AWS_MINIMAL_AMI" \
        --key-name "$AWS_SSH_KEYNAME" \
        --security-group-ids "$SG_ID" \
        --instance-type "t2.nano" \
        --query 'Instances[].InstanceId' \
        --output text
)

echo "AWS Instance ID: $AWS_INSTANCEID"

AWS_PUBLICIP=$(
  aws --output text \
      --query 'Reservations[].Instances[].PublicIpAddress' \
        ec2 \
          describe-instances --instance-id "$AWS_INSTANCEID"
)

echo "Public IP: $AWS_PUBLICIP"

retries=0
repeat=true

# Retry forever until a succesful SSH connection is established
while "$repeat"; do
  ((retries+=1)) &&
  echo "Try number $retries..." &&
  ssh -o ConnectTimeout="$SSH_TIMEOUT" -o StrictHostKeyChecking=no -D 50000 -i "$SSH_KEYPATH" ec2-user@"$AWS_PUBLICIP" && repeat=false
  if "$repeat"; then
    sleep 1
  fi
done

aws ec2 terminate-instances --instance-ids "$AWS_INSTANCEID"
