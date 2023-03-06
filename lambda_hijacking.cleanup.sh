export AWS_PAGER=""

# The following variables should be set in the lambda_hijacking.cleanup.config
# ADMIN_AWS_ACCESS_KEY 
# ADMIN_AWS_SECRET_KEY 
# ADMIN_SESSION_TOKEN
. ./lambda_hijacking.cleanup.config

############################################################## This code is different for automated demo attack
export AWS_ACCESS_KEY_ID=$ADMIN_AWS_ACCESS_KEY
export AWS_SESSION_TOKEN=$ADMIN_SESSION_TOKEN
export AWS_SECRET_ACCESS_KEY=$ADMIN_AWS_SECRET_KEY
##############################################################

sleep 5
echo 'aws: detach-role-policy EC2'
aws iam detach-role-policy --role-name EC2Admin --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess  
aws iam delete-role --role-name EC2Admin

sleep 5
echo 'aws: detach-role-policy S3'
aws iam detach-role-policy --role-name S3Admin --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess  
aws iam delete-role --role-name S3Admin

sleep 5
echo 'pacu: --set-keys'
../pacu/cli.py --session backdoor_roles --set-keys backdoor_roles,$AWS_ACCESS_KEY_ID,$AWS_SECRET_ACCESS_KEY,$AWS_SESSION_TOKEN

sleep 5
echo 'pacu: --cleanup'
../pacu/cli.py --session backdoor_roles --exec --module-name lambda__backdoor_new_roles --module-args='--cleanup'



