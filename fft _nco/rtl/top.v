module top(
    input                   sys_clk,
    input                   sys_rst_n,
    input           [9:0]   data_in
);

//AD模块初始化
assign ad_clk = ~clk_catch;   //采样频率


//NCOcore端口初始化
wire    signed  [14:0]  oc_sin;
wire                    out_valid;

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
wire    signed  [11:0]  data;
wire    signed  [11:0]  xkre;               //O，输出数据的实部，二进制补码数据
wire    signed  [11:0]  xkim;               //O，输出数据的虚部

assign sink_error = 2'b00;
assign source_ready = 1'b1;
assign inverse = 1'b0;                      //FFT正变换
assign sink_imag = 11'd0;                   //输入数据虚部接地

nco u_nco(
    .phi_inc_i      (15'd16384),       //相位增量
    .clk            (nco_clk),
    .reset_n        (sys_rst_n),
    .clken          (1'b1),         //时钟允许信号
    .fsin_o         (oc_sin),       //本振正弦信号
    .out_valid      (out_valid)     //输出有效信号
);

ad u_ad(
    .clk            (clk_catch),
    .rst_n          (sys_rst_n),
    .signal         (oc_sin),
    .ad_data        (data)
);

cnt u_cnt(
    .clk            (sys_clk),
    .rst_n          (sys_rst_n),
    .sink_sop       (sink_sop),
    .sink_eop       (sink_eop),
    .sink_valid     (sink_valid)
);

fftcore u_fftcore(
    .clk            (sys_clk),
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

pll u_pll(
    .inclk0         (sys_clk),
    .c0             (clk_catch),
    .c1             (nco_clk)           //4kHz
);

endmodule