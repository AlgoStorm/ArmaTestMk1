# Explanation: Gojo returns traffic to Liberdade—doctors need answers, not one-way tunnels.
resource "aws_route" "Gojo_to_libby_route01" {
  route_table_id         = aws_route_table._private_rt01.id
  destination_cidr_block = var.saopaulo_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.Gojo_tgw01.id
}
