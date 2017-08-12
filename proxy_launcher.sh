#!/bin/bash


SSH_KEYPATH="~/.ssh/milos-london-aws.pem"
SG_ID="sg-a044f2c9"
AWS_SSH_KEYNAME="milos-london-aws"
export AWS_DEFAULT_REGION="eu-west-2"

AWS_MINIMAL_AMI=$(
  aws --query 'Images[*].[Name,ImageId]' \
      --output text \
      ec2 describe-images \
        --owners amazon \
        --filters \
          "Name=root-device-type,Values=ebs" \
          "Name=architecture,Values=x86_64" \
          "Name=virtualization-type,Values=hvm" \
          "Name=image-type,Values=machine" \
          "Name=is-public,Values=true" | grep minimal | sort | tail -n1 | awk '{print $2}'
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

while "$repeat"; do
  ((retries+=1)) &&
  echo "Try number $retries..." &&
  ssh -oStrictHostKeyChecking=no -D 50000 -i "$SSH_KEYPATH" ec2-user@"$AWS_PUBLICIP" && repeat=false
  if "$repeat"; then
    sleep 5
  fi
done

aws ec2 terminate-instances --instance-ids "$AWS_INSTANCEID"
