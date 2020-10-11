module cnt(
    input           clk,
    input           rst_n,
    output          sink_sop,
    output          sink_eop,
    output          sink_valid
);

reg [22:0]  count;
reg         sop;
reg         eop;
reg         valid;

assign sink_sop = sop;
assign sink_eop = eop;
assign sink_valid = valid;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        eop <= 1'b0;
        sop <= 1'b0;
        valid <= 1'b0;
        count <= 22'b0;
    end
    else begin
        count <= count + 22'b1;                 //信号起始标记
        if(count==22'b1)
            sop <= 1'b1;
        else
            sop <= 1'b0;

        if(count==22'd2500001)                    //信号结束标记
            eop <= 1'b1;
        else
            eop <= 1'b0;

        if(count>=22'd1 & count <=22'd2500000)
            valid <= 1'b1;
        else
            valid <= 1'b0;
    end
end

endmodule