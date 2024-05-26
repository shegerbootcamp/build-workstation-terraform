### How to provision server

```
terrafom init
terrafom plan
terraform apply
```

### How to fetch private keys from ssm parameter store 

```
aws ssm get-parameter --name "/ec2/key-pair/jemal.master/private-rsa-key-pem" --output text --query Parameter.Value >> jemal.master.pem
```