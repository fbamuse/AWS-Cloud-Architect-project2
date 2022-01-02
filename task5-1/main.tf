# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
    access_key = "*************"
    secret_key = "*************"
    region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket  = "tfstate-uda"
    region  = "us-east-1"
    key     = "production.tfstate"
    encrypt = true
  }
}


# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "Udacity_T2" {
	ami = "ami-0ed9277fb7eb570c9"
	count			=	4
    instance_type	= 	"t2.micro"

    subnet_id = "subnet-074d29de46c19fd39"
    tags = {
    	#Name = "${format("Udacity T2 %02d", count.index)}"
		Name = "Udacity T2"
    }

}

# TODO: provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "Udacity_M4" {
	ami = "ami-0ed9277fb7eb570c9"
	count			=	2
    instance_type	= 	"m4.large"

    subnet_id = "subnet-074d29de46c19fd39"
    tags = {
        #Name = "${format("Udacity M4 %02d", count.index + 1)}"
		Name = "Udacity M4"
    }

}
