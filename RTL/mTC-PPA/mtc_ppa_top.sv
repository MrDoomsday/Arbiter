module mtc_ppa_top #(
    parameter WIDTH_N = 2,//размер входного вектора request
    parameter AMOUNT_M = 1//максимальное число допустимых одновременных grant'ов
)(
    input   logic                                   clk,
    input   logic                                   reset_n,

    input   logic     [WIDTH_N-1:0]                 req_i,
    input   logic                                   req_vld_i,
    output  logic                                   req_rdy_o,

    output  logic     [WIDTH_N-1:0]                 gnt_o,
    output  logic                                   gnt_vld_o,
    input   logic                                   gnt_rdy_i
);

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************         DECLARATION         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    //global pointer (mask)
    logic   [WIDTH_N-1:0]               hptr, hptr_next;
    logic                               hptr_vld;

    //mpe one and two
    logic     [AMOUNT_M-1:0][WIDTH_N-1:0]       gnt_out_mpeth_one, gnt_out_mpeth_two;
    logic                                       gnt_vld_out_mpeth_one, gnt_vld_out_mpeth_two;

    //mux mpe
    logic     [AMOUNT_M-1:0][WIDTH_N-1:0]     gnt_out_mpe_mux;
    logic                                     gnt_vld_mpe_mux;

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            INSTANCE         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    mtc_ppa_pr_encoder #(
        .WIDTH_N    (WIDTH_N),//размер входного вектора request
        .AMOUNT_M   (AMOUNT_M)//максимальное число допустимых одновременных ответов
    ) mpeth_one (
        .clk        (clk),
        .reset_n    (reset_n),

        .req_i      (req_i & hptr),
        .req_vld_i  (req_vld_i),
        .req_rdy_o  (req_rdy_o),

        .gnt_o      (gnt_out_mpeth_one),
        .gnt_vld_o  (gnt_vld_out_mpeth_one),
        .gnt_rdy_i  (1'b1)
    );

    mtc_ppa_pr_encoder #(
        .WIDTH_N    (WIDTH_N),//размер входного вектора request
        .AMOUNT_M   (AMOUNT_M)//максимальное число допустимых одновременных ответов
    ) mpeth_two (
        .clk        (clk),
        .reset_n    (reset_n),

        .req_i      (req_i),
        .req_vld_i  (req_vld_i),
        .req_rdy_o  (),

        .gnt_o      (gnt_out_mpeth_two),
        .gnt_vld_o  (gnt_vld_out_mpeth_two),
        .gnt_rdy_i  ()
    );

    mtc_ppa_mux_mpe #(
        .WIDTH_N    (WIDTH_N),//размер входного вектора request
        .AMOUNT_M   (AMOUNT_M)//максимальное число допустимых одновременных ответов
    ) mux_mpe (
        .clk            (clk),
        .reset_n        (reset_n),

        .in_gnts_i      (gnt_out_mpeth_one),//th'
        .in_gntss_i     (gnt_out_mpeth_two),//th''
        .in_gnt_vld_i   (gnt_vld_out_mpeth_one & gnt_vld_out_mpeth_two),
        .in_gnt_rdy_o   (),

        .out_gnt_o      (gnt_out_mpe_mux),
        .out_gnt_vld_o  (gnt_vld_mpe_mux),
        .out_gnt_rdy_i  (1'b1)
    );

    mtc_ppa_mux_hptr #(
        .WIDTH_N    (WIDTH_N),//размер входного вектора request
        .AMOUNT_M   (AMOUNT_M)//максимальное число допустимых одновременных ответов
    ) mux_hptr (
        .clk                (clk),
        .reset_n            (reset_n),

        .in_gnt_i           (gnt_out_mpe_mux),//th'
        .in_gntss_i         (gnt_out_mpeth_two),//th''
        .in_gnt_vld_i       (gnt_vld_mpe_mux),
        .in_gnt_rdy_o       (),

        .out_ptr_next_o     (hptr_next),
        .out_ptr_next_vld_o (hptr_vld),
        .out_ptr_next_rdy_i (1'b1)
    );

    mtc_ppa_gnt_converter #(
        .WIDTH_N    (WIDTH_N),//размер входного вектора request
        .AMOUNT_M   (AMOUNT_M)//максимальное число допустимых одновременных ответов
    ) gnt_converter (
    .clk                (clk),
    .reset_n            (reset_n),

    .in_gnt_i           (gnt_out_mpe_mux),//th'
    .in_gnt_vld_i       (gnt_vld_mpe_mux),
    .in_gnt_rdy_o       (),

    .out_gnt_o          (gnt_o),
    .out_gnt_vld_o      (gnt_vld_o),
    .out_gnt_rdy_i      (1'b1)
);

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    always_ff @ (posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            hptr <= {WIDTH_N{1'b0}};
        end
        else if(hptr_vld) begin
            hptr <= hptr_next;
        end
    end
endmodule