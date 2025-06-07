# Automating Setting up AWS Account for the bootcamp labs

This is taking what we did in Setup Cloud Environment, which was click ops, and automating it, in my case I choose to automate in Terraform/openTofu. Additionally, I utilized Amazon Q CLI to assist me in ensuring I set up my .tf files correctly to avoid as many forgetful moments as possible. I did this full well knowing LLMs are not always right and knew that I would most likely have to deal with bugs/issues from the LLM's code. As someone who does this daily to speed up my development in multiple ways, not just generating code, I am comfortable dealing with dealing with LLM's and their not always correct responses.


## Design Decisions

We will be using AWS S3 to store our state file, and will be using the S3 Object Locking to do everything in S3 and not have to worry about a DynamoDB table. This S3 bucket I created manually as in my opinion it is easier, and also ensures that if we accidently run terraform destroy when we didn't mean to, that we don't loose the bucket, especially if you decide to have one bucket for all state files.

