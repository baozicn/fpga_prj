// axis8_to_axis128.v
// Pack 8-bit grayscale pixels (1 pix/clk) into 128-bit AXIS words (16 pix/beat).
// Preserves SOF via tuser on first pixel; sets tlast on last beat of each line.
module axis8_to_axis128 #(
    parameter IMG_W = 1920
)(
    input  wire        clk,
    input  wire        rst_n,
    // 8-bit in
    input  wire        s_tvalid,
    input  wire [7:0]  s_tdata,
    input  wire        s_tuser,
    input  wire        s_tlast,
    // 128-bit out
    output reg         m_tvalid,
    output reg [127:0] m_tdata,
    output reg         m_tuser,
    output reg         m_tlast
);
    reg [3:0]  cnt;
    reg [127:0] shreg;
    reg [15:0] x;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin cnt<=0; shreg<=0; x<=0; m_tvalid<=0; m_tdata<=0; m_tuser<=0; m_tlast<=0; end
        else begin
            m_tvalid<=1'b0; m_tuser<=1'b0; m_tlast<=1'b0;
            if(s_tvalid) begin
                // shift left by 8 and insert new pixel at LSB (little-endian inside beat)
                shreg <= {shreg[119:0], s_tdata};
                cnt <= cnt + 1'b1;
                if(s_tuser && (cnt==0)) m_tuser <= 1'b1;
                if(cnt==4'd15) begin
                    m_tvalid <= 1'b1;
                    m_tdata  <= {shreg[119:0], s_tdata};
                    // End of line when x points to last 16-pixel group
                    m_tlast  <= s_tlast;
                    cnt <= 0;
                end
                if(s_tlast) x <= 0; else x <= x + 1'b1;
            end
        end
    end
endmodule
