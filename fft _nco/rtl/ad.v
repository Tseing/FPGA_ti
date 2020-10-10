module ad(
    input                   clk,
    input                   rst_n,
    input   signed  [11:0]  signal,
    output  signed  [11:0]  ad_data
);

reg [11:0]  ad_reg;
assign ad_data = ad_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ad_reg <= 12'd0;
    else
        ad_reg <= signal;
end

endmodule