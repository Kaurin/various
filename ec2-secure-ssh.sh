#!/bin/sh -e

####################################################
### These variables need to be set
####################################################

### Security group ID (VPC). EC2-Classic not supported
SG="sg-xxxxxx"

### This script relies on SSH profiles defined in ~/.ssh/config
SSH_PROFILE_NAME="my_ssh_profile"
MYIP_PROVIDER_CURL_STRING="https://ifconfig.co"

### Use/change these if you wish, and if you know what they are
# export AWS_DEFAULT_PROFILE="default"
# export AWS_DEFAULT_REGION="eu-west-1"
# export AWS_CONFIG_FILE=""
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""
# export AWS_SESSION_TOKEN=""

####################################################
### End of the variable block.
### Don't change stuff below 
### unless you know what you are doing
####################################################

echo "Getting our IP from $MYIP_PROVIDER_CURL_STRING..."
MYIP="$(/usr/bin/curl -4s $MYIP_PROVIDER_CURL_STRING)"
echo "Got it! It's $MYIP"

# Reusable in both autorize/revoke
JSON="{\"DryRun\":false,\"GroupId\":\"$SG\",\"IpProtocol\":\"tcp\",\"FromPort\":22,\"ToPort\":22,\"CidrIp\":\"$MYIP/32\"}"

echo "Autorizing SG..."
aws ec2 authorize-security-group-ingress --cli-input-json "$JSON"
echo "Authorize successful"

echo "SSH-ing into EC2 instance"
ssh "$SSH_PROFILE_NAME"
echo "SSH session over"

echo "Revoking SSH access"
aws ec2 revoke-security-group-ingress --cli-input-json "$JSON"
echo "Revoke succesful. Good bye!"
