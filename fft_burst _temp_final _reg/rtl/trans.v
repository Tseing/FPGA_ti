module trans(
    input               clk,
    input               rst_n,
    input       [9:0]   data_o,
    input       [10:0]  data_qsub,
    output      [11:0]  data
);

reg [10:0]  data_mult;
reg [11:0]  data_q;
assign data = data_q;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_mult <= 11'd0;
        data_q <= 12'd0;
    end
    else begin
        data_mult <= {data_o[9:0], 1'b0};
        data_q <= (data_qsub[10]==1'b0) ? {1'b0, data_mult} : {1'b1, ~data_mult+1'b1};
    end
end

endmodule