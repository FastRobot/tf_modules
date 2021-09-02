RunAtlantis module
=======

Module to stand up a cheap [RunAtlantis](https://www.runatlantis.io) setup to perform CI/CD on a terragrunt live style repo. 

Should maintain:
* ECS (Fargate Spot market) runatlantis container
* ALB with SSL cert
    * Auth0 authN/authZ for humans
    * Github hooks allowed via IP
  

Based on process from: 
* https://medium.com/@sandrinodm/securing-your-applications-with-aws-alb-built-in-authentication-and-auth0-310ad84c8595