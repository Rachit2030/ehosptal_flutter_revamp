brew install awscli  

docker build --no-cache --platform linux/amd64 -t ehospital-flutter:latest .  

docker tag ehospital-flutter:latest 938595517074.dkr.ecr.ca-central-1.amazonaws.com/ehospital-flutter:latest

docker push 509399620412.dkr.ecr.ca-central-1.amazonaws.com/ehospital-flutter:latest                        

aws ecs update-service \  --cluster ehospital-cluster \                        
  --service app-service \
  --force-new-deployment \
  --region ca-central-1


aws ecr get-login-password --region ca-central-1 | docker login --username AWS --password-stdin 938595517074.dkr.ecr.ca-central-1.amazonaws.com

aws login

aws cloudformation describe-stacks \
  --stack-name ehospital-stack-latest \
  --region ca-central-1 \
  --query 'Stacks[0].Outputs'            


  aws cloudformation create-stack \  
  --stack-name ehospital-stack-latest \
  --template-body file://cloudformation.yaml \
  --parameters ParameterKey=ContainerImage,ParameterValue=509399620412.dkr.ecr.ca-central-1.amazonaws.com/ehospital-flutter:latest \
  --capabilities CAPABILITY_IAM \
  --region ca-central-1

  aws elbv2 describe-load-balancers \ 
  --region ca-central-1 \
  --query 'LoadBalancers[?LoadBalancerName==`ehospital-alb`].DNSName' \
  --output text

  aws ecr create-repository --repository-name ehospital-flutter --region ca-central-1                         


  i-0774f4cec5f6b7b26
  3.98.136.74