# Route Tokyo CIDR via Liberdade TGW in private route table
resource "aws_route" "liberdade_to_shinjuku_tgw" {
  route_table_id         = aws_route_table.libby_private_rt01.id
  # destination_cidr_block = local.Gojo_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.libby_tgw01.id
}
