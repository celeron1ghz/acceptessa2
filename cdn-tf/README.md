# SETUP

### INSTALL NODEJS LIBRARY
```
cd lambda/origin-response
npm install --arch=x64 --platform=linux sharp
```

### BUILD CDN
```
cd tf
terraform init
terraform apply
```

### DEPLOY ERROR PAGE
```
aws s3 sync ./bucket-contents s3://bucket
```
