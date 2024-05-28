module mtc_ppa_mux_hptr #(
    parameter WIDTH_N = 2,//размер входного вектора request
    parameter AMOUNT_M = 1//максимальное число допустимых одновременных grant'ов
)(
    input   logic                                   clk,
    input   logic                                   reset_n,

    input   logic     [AMOUNT_M-1:0][WIDTH_N-1:0]   in_gnt_i,//th'
    input   logic     [AMOUNT_M-1:0][WIDTH_N-1:0]   in_gntss_i,//th''
    input   logic                                   in_gnt_vld_i,
    output  logic                                   in_gnt_rdy_o,

    output  logic     [WIDTH_N-1:0]                 out_ptr_next_o,
    output  logic                                   out_ptr_next_vld_o,
    input   logic                                   out_ptr_next_rdy_i
);

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************         DECLARATION         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    logic   [AMOUNT_M-1:0]                  selector;
    genvar                                  i;
    logic   [AMOUNT_M-2:0][WIDTH_N-1:0]     up_mux;//для каскада мультиплексоров выбора
    logic   [AMOUNT_M-1:0][WIDTH_N-1:0]     in_gnt_rotright;//th'


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    assign in_gnt_rdy_o = out_ptr_next_rdy_i;
    
    always_comb begin
        for(int i = 0; i < AMOUNT_M; i++) begin
            selector[i] = in_gntss_i[i][WIDTH_N-1];//нас интересуют только старшие биты вектора in_gntss_i
            //in_gnt_rotright[i] = {1'b0, in_gnt_i[i][WIDTH_N-1:1]};
            in_gnt_rotright[i] = {in_gnt_i[i][WIDTH_N-2:0], 1'b0};
        end
    end


    generate
        assign up_mux[0] = selector[0] ? in_gnt_rotright[0] : {WIDTH_N{1'b0}};
        for(i = AMOUNT_M-2; i > 0; i--) begin: gen_mux_hptr
            assign up_mux[i] = selector[i] ? in_gnt_rotright[i] : up_mux[i-1];
        end
    endgenerate

    assign out_ptr_next_o = selector[AMOUNT_M-1] ? in_gnt_rotright[AMOUNT_M-1:0] : up_mux[AMOUNT_M-2];
    assign out_ptr_next_vld_o = selector > 0;


endmodule