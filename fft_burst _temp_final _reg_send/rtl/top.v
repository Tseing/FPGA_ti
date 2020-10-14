module top(
    input                   sys_clk,
    input                   sys_rst_n,
    input           [9:0]   data_in,
    output          [39:0]  data_out,
    output                  catch_flag,
    output                  ad_clk,
    output                  ad_oe
);

//AD模块初始化
assign ad_oe = 1'b0;
assign ad_clk = ~clk_catch;   //采样频率


//数据发送模块
wire    [23:0]  amp_1;
wire    [23:0]  amp_2;
wire    [23:0]  amp_3;
wire    [23:0]  amp_4;
wire    [23:0]  amp_5;
wire    [39:0]  THD;
wire    [25:0]  sum;
wire    [51:0]  mult_sum; 

assign data_out = source_sop || catch_flag ? 1'd0 : THD;
assign sum = amp_2+amp_3+amp_4+amp_5;/*synthesis keep*/
assign mult_sum = 27'd100000000*sum;/*synthesis keep*/
assign THD = mult_sum/amp_1;


//FFT频谱计算模块
wire    signed  [24:0]  amp;
wire    signed  [23:0]  xkre_square, xkim_square;
assign xkre_square = xkre * xkre;
assign xkim_square = xkim * xkim;
assign amp = xkre_square + xkim_square;


//AD数据格式转换初始化
wire    signed  [10:0]  data_sub;
wire    signed  [10:0]  data_qsub;
wire            [9:0]   data_o;
wire            [10:0]  data_mult;

assign data_sub = {1'b0, data_in[9:0]};//data_in转数据格式，扩位转signed
assign data_o = (data_qsub[10]==1'b0) ? data_qsub[9:0] : ~data_qsub[9:0]+1'b1;  //去符号原码，10bit


//FFTcore端口初始化
wire                    inverse;            //I，为1时进行IFFT，为0时进行FFT
wire                    sink_ready;         //O，FFT准备好接受数据时置位
wire                    source_ready;       //I,下传流模块可接受数据时置位
wire                    sink_valid;         //I，有效标记，sin_valid和sink_ready都置位时开始传输
wire                    sink_sop;           //I，高电平表示1帧数据载入开始
wire                    sink_eop;           //I，高电平表示1帧数据载入结束
wire    signed  [11:0]  sink_imag;          //I，输入数据的虚部，二进制补码
wire            [1:0]   sink_error;         //I，表示载入数据状态，一般置0
wire            [1:0]   source_error;       //O，表示FFT出现的错误
wire                    source_sop;         //O，高电平表示1帧数据转换开始
wire                    source_eop;         //O，高电平表示1帧数据转换结束
wire            [5:0]   source_exp;
wire                    source_valid;
wire    signed  [11:0]  data;               //用于FFT数据
wire    signed  [11:0]  xkre;               //O，输出数据的实部，二进制补码数据
wire    signed  [11:0]  xkim;               //O，输出数据的虚部

assign sink_error = 2'b00;
assign source_ready = 1'b1;
assign inverse = 1'b0;                      //FFT正变换
assign sink_imag = 11'd0;                   //输入数据虚部接地

assign data_valid = source_valid;

save u_save(
    .clk            (sys_clk),
    .rst_n          (sys_rst_n),
    .source_sop     (source_sop),
    .amp            (amp[23:0]),
    .amp_1          (amp_1),
    .amp_2          (amp_2),
    .amp_3          (amp_3),
    .amp_4          (amp_4),
    .amp_5          (amp_5),
    .catch_flag     (catch_flag)
);

trans u_trans(
    .clk            (clk_catch),
    .rst_n          (sys_rst_n),
    .data_o         (data_o),
    .data_qsub      (data_qsub),
    .data           (data)
);

cnt u_cnt(
    .clk            (sys_clk),
    .rst_n          (sys_rst_n),
    .sink_sop       (sink_sop),
    .sink_eop       (sink_eop),
    .sink_valid     (sink_valid)
);

fftcore u_fftcore(
    .clk            (clk_catch),
    .reset_n        (sys_rst_n),
    .sink_valid     (sink_valid),
    .sink_ready     (sink_ready),
    .sink_error     (sink_error),
    .sink_sop       (sink_sop),
    .sink_eop       (sink_eop),
    .sink_real      (data),
    .sink_imag      (sink_imag),

    .inverse        (inverse),
    .source_valid   (source_valid),
    .source_ready   (source_ready),
    .source_error   (source_error),
    .source_sop     (source_sop),
    .source_eop     (source_eop),
    .source_exp     (source_exp),
    .source_real    (xkre),
    .source_imag    (xkim)
);

sub u_sub(
    .dataa          (data_sub),         //data_sub - 512
    .result         (data_qsub)
);

pll u_pll(
    .inclk0         (sys_clk),
    .c0             (clk_catch)         //1024kHz
);

endmodule