`timescale 1ns/1ps
module tb_axis_1080p;
    localparam W=1920, H=1080;
    reg clk=0, rst_n=0;
    always #5 clk=~clk;
    reg         s_tvalid; reg  [7:0]  s_tdata; reg s_tuser; reg s_tlast;
    wire        e_tvalid; wire [7:0]  e_tdata; wire e_tuser; wire e_tlast;
    wire        d_tvalid; wire [7:0]  d_tdata; wire d_tuser; wire d_tlast;
    reg [7:0] frame0 [0:W*H-1]; reg [7:0] frame1 [0:W*H-1]; integer fd_sobel, fd_diff; integer idx, x, y;
    axis_sobel3x3 #(.IMG_W(W), .IMG_H(H), .THRESH(80)) u_sobel ( .clk(clk), .rst_n(rst_n), .s_tvalid(s_tvalid), .s_tdata(s_tdata), .s_tuser(s_tuser), .s_tlast(s_tlast), .m_tvalid(e_tvalid), .m_tdata(e_tdata), .m_tuser(e_tuser), .m_tlast(e_tlast) );
    axis_frame_diff #(.IMG_W(W), .IMG_H(H), .THRESH(25)) u_fdiff ( .clk(clk), .rst_n(rst_n), .s_tvalid(s_tvalid), .s_tdata(s_tdata), .s_tuser(s_tuser), .s_tlast(s_tlast), .m_tvalid(d_tvalid), .m_tdata(d_tdata), .m_tuser(d_tuser), .m_tlast(d_tlast) );
    initial begin
        $readmemh("sim/frame0.mem", frame0); $readmemh("sim/frame1.mem", frame1); fd_sobel = $fopen("sim/sobel_out.mem","w"); fd_diff  = $fopen("sim/fdiff_out.mem","w"); s_tvalid=0; s_tdata=0; s_tuser=0; s_tlast=0; #200; rst_n=1; #100;
        idx=0; s_tuser=1; for(y=0;y<H;y=y+1) begin for(x=0;x<W;x=x+1) begin s_tvalid=1; s_tdata=frame0[idx]; idx=idx+1; s_tlast=(x==W-1); @(posedge clk); s_tuser=0; if(e_tvalid && (e_tdata===e_tdata)) $fwrite(fd_sobel, "%02X\n", e_tdata); if(d_tvalid && (d_tdata===d_tdata)) $fwrite(fd_diff, "%02X\n", d_tdata); end s_tvalid=0; s_tlast=0; repeat(4) @(posedge clk); end
        repeat(1000) @(posedge clk);
        idx=0; s_tuser=1; for(y=0;y<H;y=y+1) begin for(x=0;x<W;x=x+1) begin s_tvalid=1; s_tdata=frame1[idx]; idx=idx+1; s_tlast=(x==W-1); @(posedge clk); s_tuser=0; if(e_tvalid && (e_tdata===e_tdata)) $fwrite(fd_sobel, "%02X\n", e_tdata); if(d_tvalid && (d_tdata===d_tdata)) $fwrite(fd_diff, "%02X\n", d_tdata); end s_tvalid=0; s_tlast=0; repeat(4) @(posedge clk); end
        repeat(1000) @(posedge clk); $fclose(fd_sobel); $fclose(fd_diff); $finish;
    end
endmodule
