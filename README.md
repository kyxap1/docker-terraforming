## Dockerfile for git master of Terraforming

### Building Docker

```
[kyxap][workbench][2.3.1][~/terraforming/docker]
$ ls -la
total 16
drwxrwxr-x 2 kyxap kyxap 4096 Jul 13 22:12 .
drwxrwxr-x 8 kyxap kyxap 4096 Jul 13 22:11 ..
-rw-rw-r-- 1 kyxap kyxap  377 Jul 13 22:10 Dockerfile
-rw-rw-r-- 1 kyxap kyxap   59 Jul 13 22:12 README.md
[kyxap][workbench][2.3.1][~/terraforming/docker]
$ docker build -t fasten.com/terraforming --rm .
Sending build context to Docker daemon 3.072 kB
Step 1 : FROM ruby:2.3.1-alpine
 ---> c872d09a2f2e
Step 2 : MAINTAINER Daisuke Fujita <dtanshi45@gmail.com> (@dtan4)
 ---> Using cache
 ---> 1c08fd5e4377
Step 3 : RUN apk add --no-cache git
 ---> Using cache
 ---> 732bdf82b170
Step 4 : RUN git clone https://github.com/dtan4/terraforming.git /app/
 ---> Using cache
 ---> e9738875ab09
Step 5 : WORKDIR /app
 ---> Using cache
 ---> 06afe264f5b0
Step 6 : RUN apk add --no-cache --update bash g++ make     && bundle install -j4 --without test development --system     && apk del g++ make
 ---> Using cache
 ---> ed5185b79e16
Step 7 : RUN bash /app/script/setup
 ---> Using cache
 ---> c589ccffcef2
Step 8 : CMD terraforming help
 ---> Using cache
 ---> 39728498739e
Successfully built 39728498739e
```

### Running Docker with aws shared credentials file
```
[kyxap][workbench][2.3.1][~/terraforming/docker]
$ docker run --rm -v ~/.aws/credentials:/root/.aws/credentials:ro fasten.com/terraforming terraforming vpc --profile=fasten.ru --region=eu-central-1 --tfstate
{
  "version": 1,
  "serial": 1,
  "modules": [
    {
      "path": [
        "root"
      ],
      "outputs": {
      },
      "resources": {
        "aws_vpc.develop": {
          "type": "aws_vpc",
          "primary": {
            "id": "vpc-1ff2c876",
            "attributes": {
              "cidr_block": "10.40.0.0/16",
              "enable_dns_hostnames": "true",
              "enable_dns_support": "true",
              "id": "vpc-1ff2c876",
              "instance_tenancy": "default",
              "tags.#": "1"
            }
          }
        }
      }
    }
  ]
}
```
### Wrote terraforming shell wrapper with multiregional support. Supports docker out of the box, allowing to use container as a plain script.
### Just copy script to ${PATH}
```
[kyxap@workbench:~/fasten-terraform/ru-testing]
$ time COUNTRY=us terraforming dumpall

real    12m50.014s
user    0m0.845s
sys     0m0.665s

[kyxap@workbench:~/fasten-terraform/ru-testing/tf_outdir]
$ tree  -N -d
.
†€€ ru
šš „€€ fasten.ru
šš     †€€ eu-central-1
šš     †€€ eu-west-1
šš     †€€ us-east-1
šš     †€€ us-west-1
šš     „€€ us-west-2
„€€ us
    „€€ fasten.us
        †€€ eu-central-1
        †€€ eu-west-1
        †€€ us-east-1
        †€€ us-west-1
        „€€ us-west-2

14 directories

}
```
###
