FROM node:12

LABEL "com.github.actions.name"="S3 Deploy Action"
LABEL "com.github.actions.description"="Installs and runs npm command, syncs ouput to an AWS S3 bucket and invalidates an AWS CloudFront distribution"
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="green"

LABEL version="1.0.0"
LABEL repository="https://github.com/mirceapreotu/s3-deploy-action"
LABEL homepage="https://mirceapreotu.com/"
LABEL maintainer="Mircea Preotu <mircea@incognicode.com>"

RUN apt-get update && apt-get install -y zip && rm -rf /var/lib/apt/lists/*
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip
RUN ./aws/install && aws --version

CMD ["node"]

ENTRYPOINT ["/entrypoint.sh"]