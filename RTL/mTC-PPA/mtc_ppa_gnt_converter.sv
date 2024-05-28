module mtc_ppa_gnt_converter #(
    parameter WIDTH_N = 2,//размер входного вектора request
    parameter AMOUNT_M = 1//максимальное число допустимых одновременных grant'ов
)(
    input   logic                                   clk,
    input   logic                                   reset_n,

    input   logic     [AMOUNT_M-1:0][WIDTH_N-1:0]   in_gnt_i,//th'
    input   logic                                   in_gnt_vld_i,
    output  logic                                   in_gnt_rdy_o,

    output  logic     [WIDTH_N-1:0]                 out_gnt_o,
    output  logic                                   out_gnt_vld_o,
    input   logic                                   out_gnt_rdy_i
);

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************         DECLARATION         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    logic [AMOUNT_M-1:0][WIDTH_N-1:0] edge_detector;

    function logic [WIDTH_N-1:0] generate_gnt(logic [AMOUNT_M-1:0][WIDTH_N-1:0] data);
        logic [WIDTH_N-1:0] result;
        result = 0;
        for(int i = 0; i < AMOUNT_M; i++) begin
            result |= data[i];
        end
        return result;
    endfunction

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    always_comb begin
        for(int i = 0; i < AMOUNT_M; i++) begin
            for(int j = 0; j < WIDTH_N; j++) begin
                if(j == 0) begin
                    edge_detector[i][j] = in_gnt_i[i][j] ^ 1'b0;
                end
                else begin
                    edge_detector[i][j] = in_gnt_i[i][j] ^ in_gnt_i[i][j-1];
                end
            end
        end
    end

    assign out_gnt_o = generate_gnt(edge_detector);
    assign out_gnt_vld_o = in_gnt_vld_i;
    assign in_gnt_rdy_o = out_gnt_rdy_i;


endmodule