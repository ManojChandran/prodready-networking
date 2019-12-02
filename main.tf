#------------------------------root/main.tf-------------------------------
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws-region}"
}

## Stores the state file back up in s3 bucket
## interpolations cannot be used becasue the actvity is done initial stage
## need to create s3 bucket and folder prior to using the backend
#terraform {
#  backend "s3" {
#    bucket = "myterraformstatebackupfile0002"
#    key    = "terraform/terraform.tfstate"
#    region = "us-east-1"
#  }
#}

# Deploy VPC and attach IGW
module "vpc-igw" {
  source   = "./modules/10_VPC_IGW"
  vpc-cidr = "${var.vpc-cidr}"
}

# Deploy public subnet
module "public-subnet" {
  source           = "./modules/11_public_subnet"
  vpc-id           = "${module.vpc-igw.vpc-id}"
  igw-id           = "${module.vpc-igw.igw-id}"
  vpc-public-cidrs = "${var.vpc-public-cidrs}"
}

# Deploy private subnet
module "private-subnet" {
  source                 = "./modules/12_private_subnet"
  vpc-id                 = "${module.vpc-igw.vpc-id}"
  vpc-private-cidrs      = "${var.vpc-private-cidrs}"
  default-route-table-id = "${module.vpc-igw.default-route-table-id}"
}

# Deploy database subnet
module "db-subnet" {
  source       = "./modules/13_db_subnet"
  vpc-id       = "${module.vpc-igw.vpc-id}"
  vpc-db-cidrs = "${var.vpc-db-cidrs}"
}

# Deploy VPC flow logs
module "vpc-flow-logs" {
  source = "./modules/14_vpc_flow_logs"
  vpc-id = "${module.vpc-igw.vpc-id}"
}
