#-----------------------11_Public_subnet/main.tf---------------------------
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
#-------------variable section----------------------
variable "vpc-id" {}
variable "igw-id" {}
variable "vpc-public-cidrs" {}

#-------------data section--------------------------
# get availability zone from specified AWS region
data "aws_availability_zones" "available" {}

#-------------control section-----------------------
# Public route table
resource "aws_route_table" "oouve-pub-route-table" {
  vpc_id = "${var.vpc-id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.igw-id}"
  }

  tags = {
    Name = "oouve-pub-route-table"
  }
}

# create public subnet
resource "aws_subnet" "oouve-pub-subnet" {
  count                   = "${length(var.vpc-public-cidrs)}"
  vpc_id                  = "${var.vpc-id}"
  cidr_block              = "${var.vpc-public-cidrs[count.index]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name = "oouve-pub-subnet{count.index +1}"
  }
}

# Associating public subnet route table
resource "aws_route_table_association" "oouve-pub-subnet-association" {
  count          = "${length(var.vpc-public-cidrs)}"
  subnet_id      = "${aws_subnet.oouve-pub-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.oouve-pub-route-table.id}"

}
#-------------output section------------------------

output "public-subnet-ids" {
  value = "${aws_subnet.oouve-pub-subnet.*.id}"
}
output "public-route-table" {
  value = "${aws_route_table.oouve-pub-route-table.id}"
}
output "public-subets" {
  value = "${aws_subnet.oouve-pub-subnet.*.cidr_block}"
}
