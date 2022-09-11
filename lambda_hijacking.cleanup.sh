export AWS_PAGER=""
ADMIN_PROFILE = ''

sleep 5
echo 'aws: detach-role-policy EC2'
aws iam detach-role-policy --role-name EC2Admin --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --profile $ADMIN_PROFILE
aws iam delete-role --role-name EC2Admin --profile demolab

sleep 5
echo 'aws: detach-role-policy S3'
aws iam detach-role-policy --role-name S3Admin --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --profile $ADMIN_PROFILE
aws iam delete-role --role-name S3Admin --profile demolab

# sleep 5
# echo 'pacu: --set-keys'
# ../pacu/cli.py --session backdoor_roles --set-keys backdoor_roles,$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY,$AWS_SESSION_TOKEN

sleep 5
echo 'pacu: --cleanup'
../pacu/cli.py --session backdoor_roles --exec --module-name lambda__backdoor_new_roles --module-args='--cleanup'



