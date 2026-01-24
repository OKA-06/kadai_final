# dockerイメージのビルド(xxxはアプリ名)
docker build -t xxxxx ./ 

# ECRログイン(xxxはアプリ名)
aws ecr-public get-login-password --region ap-northeast-1  | docker login --username AWS --password-stdin public.ecr.aws/j3a2u6t5

# Dockerイメージにタグを付ける(xxxはアプリ名)
docker tag xxxxxxx samurai-kadai:latest

# ECRにDockerイメージをプッシュ(xxxはアプリ名)
docker push samurai-kadai:latest