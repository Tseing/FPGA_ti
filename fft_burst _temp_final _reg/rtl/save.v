module save(
    input               clk,
    input               rst_n,
    input               source_sop,
    input       [23:0]  amp,
    output  reg [23:0]  amp_1,
    output  reg [23:0]  amp_2,
    output  reg [23:0]  amp_3,
    output  reg [23:0]  amp_4,
    output  reg [23:0]  amp_5,
    output  reg         catch_flag
);


wire        posedge_flag;
wire        negedge_flag;
reg         sop_d0, sop_d1;
reg [7:0]   cnt;

assign negedge_flag = sop_d1 & (~sop_d0);
assign posedge_flag = (~sop_d1) & sop_d0;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        sop_d0 <= 1'd0;
        sop_d1 <= 1'd0;
    end
    else begin
        sop_d0 <= source_sop;
        sop_d1 <= sop_d0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 1'd0;
    else if(catch_flag)
        cnt <= cnt + 1'd1;
    else
        cnt <= 1'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        catch_flag <= 1'd0;
        amp_1 <= 1'd0;
        amp_2 <= 1'd0;
        amp_3 <= 1'd0;
        amp_4 <= 1'd0;
        amp_5 <= 1'd0;
    end
    else begin
        if(negedge_flag)
            catch_flag <= 1'd1;
        else if(posedge_flag) begin
            amp_1 <= 1'd0;
            amp_2 <= 1'd0;
            amp_3 <= 1'd0;
            amp_4 <= 1'd0;
            amp_5 <= 1'd0;
        end
        else begin
            case(cnt)
                8'd24:  amp_1 <= amp;
                8'd72:  amp_2 <= amp;
                8'd120: amp_3 <= amp;
                8'd168: amp_4 <= amp;
                8'd216: begin
                    amp_5 <= amp;
                    catch_flag <= 1'd0;
                end
                default: ;
            endcase
        end
    end
end

endmodule
