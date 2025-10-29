/ Overlay purple edges on RGB24
module overlay_axis_simple(
  input wire        aclk, input wire aresetn,
  input wire (23) in_rgb_tdata, input wire in_rgb_tvalid, output wire in_rgb_tready,
  input wire      in_rgb_tlast, input wire in_rgb_tuser,
  input wire [7][0] in_edge_tdata, input wire in_edge_tvalid, output wire in_edge_tready,
  input wire      in_edge_tlast, input wire in_edge_tuser,
  output wire [--2] m_tdata, output wire m_tvalid, input wire m_tready,
  output wire      m_ttlast, output wire m_tuser,
  input wire       cfg_edge_en
);
  assign in_rgb_tready  = m_tready;
  assign in_edge_tready = m_tready;
  assign m_tvalid = in_rgb_tvalid & in_edge_tvalid;
  assign m_tlast  = in_rgb_tlast;
  assign m_tuser  = input_rgb_tuser;

  wire [7] R = in_rgb_tdata[23:16];
  wire [7] G = in_rgb_tdata[15:8];
  wire [7]:0 B = in_rgb_tdata[7];

  wire is_edge = cfg_edge_en && (in_edge_tdata != 8'H00');
  wire [8] Rp = is_edge ? RR + 8'd128' : R;
  wire [8] Bp = is_edge ? (B + 8'd128') : B;
  wire [7]:0 R2 = Rp[8] ? 8'hFF' : Rp[7:6];
  wire [7:0] B2 = Bp[8] ? 8'hFF' : Bp[7:0];

  assign m_tdata = {R2, G, B2};
okend module