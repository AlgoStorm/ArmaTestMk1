# Get current AWS account ID for peering
data "aws_caller_identity" "current" {}

# Explanation: Gojo Station is the hub—Tokyo is the data authority.
resource "aws_ec2_transit_gateway" "Gojo_tgw01" {
  description = "Gojo-tgw01 (Tokyo hub)"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags        = { Name = "Gojo-tgw01" }
}

resource "aws_ec2_transit_gateway_route_table" "Gojo_tgw_rt01" {
  transit_gateway_id = aws_ec2_transit_gateway.Gojo_tgw01.id
  tags               = { Name = "Gojo-tgw-rt01" }
}

# Explanation: Gojo connects to the Tokyo VPC—this is the gate to the medical records vault.
resource "aws_ec2_transit_gateway_vpc_attachment" "Gojo_attach_tokyo_vpc01" {
  transit_gateway_id = aws_ec2_transit_gateway.Gojo_tgw01.id
  vpc_id             = aws_vpc.jarvis_vpc01.id
  subnet_ids         = [aws_subnet.jarvis_private_subnets[0].id, aws_subnet.jarvis_private_subnets[1].id]
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags               = { Name = "Gojo-attach-tokyo-vpc01" }
}

resource "aws_ec2_transit_gateway_route_table_association" "Gojo_vpc_assoc01" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.Gojo_attach_tokyo_vpc01.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Gojo_tgw_rt01.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "Gojo_vpc_prop01" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.Gojo_attach_tokyo_vpc01.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Gojo_tgw_rt01.id
}

# Explanation: Gojo opens a corridor request to libby—compute may travel, data may not.
resource "aws_ec2_transit_gateway_peering_attachment" "Gojo_to_libby_peer01" {
  count                   = var.saopaulo_tgw_id == null ? 0 : 1
  transit_gateway_id      = aws_ec2_transit_gateway.Gojo_tgw01.id
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "sa-east-1"
  peer_transit_gateway_id = var.saopaulo_tgw_id # set from Sao Paulo state output
  tags                    = { Name = "Gojo-to-libby-peer01" }
}

# Accept the corridor request in the peer region (libby / Sao Paulo) so the
# peering attachment is in an "available" state before association/routes.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "libby_accept_Gojo_peer01" {
  count                         = var.saopaulo_tgw_id == null ? 0 : 1
  provider                      = aws.saopaulo
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.Gojo_to_libby_peer01[0].id
  tags                          = { Name = "libby-accept-Gojo-peer01" }
}

resource "aws_ec2_transit_gateway_route_table_association" "Gojo_peer_assoc01" {
  count                          = var.saopaulo_tgw_id == null ? 0 : 1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.Gojo_to_libby_peer01[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Gojo_tgw_rt01.id
  
  # Wait for peering to be accepted before associating
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.libby_accept_Gojo_peer01]
}

# NOTE: Propagation is NOT supported for peering attachments - AWS limitation
# Static routes must be used instead (see Gojo_to_libby_tgw_route01 below)

resource "aws_ec2_transit_gateway_route" "Gojo_to_libby_tgw_route01" {
  count                          = var.saopaulo_tgw_id == null ? 0 : 1
  destination_cidr_block         = var.saopaulo_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.Gojo_to_libby_peer01[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.Gojo_tgw_rt01.id
  
  # Ensure peering is accepted and associated before creating routes
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment_accepter.libby_accept_Gojo_peer01,
    aws_ec2_transit_gateway_route_table_association.Gojo_peer_assoc01
  ]
}
