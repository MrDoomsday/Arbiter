module tc_ppa_arbiter #(
    parameter WIDTH_REQ = 8
)(
    input   bit     clk,
    input   bit     reset_n,

    input   logic       [WIDTH_REQ-1:0]         req_i,
    output  logic       [WIDTH_REQ-1:0]         req_rdy_o,

    output  logic       [WIDTH_REQ-1:0]         gnt_o,
    input   logic                               gnt_rdy_i
);

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            DECLARATION      ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    function logic [WIDTH_REQ-1:0] bin2thermo(logic [WIDTH_REQ-1:0] data);
        logic [WIDTH_REQ-1:0] thermocode;
        for(int i = 0; i < WIDTH_REQ; i++) begin
            //thermocode[i] = |data[0+:i];//Error: Range width must be constant expression.
            logic tmp_or;
            tmp_or = 0;

            for(int j = 0; j <= i; j++) begin 
                tmp_or |= data[j];
            end

            thermocode[i] = tmp_or;
        end
        return thermocode;
    endfunction

    function logic [WIDTH_REQ-1:0] get_gnt(logic [WIDTH_REQ-1:0] data);
        logic [WIDTH_REQ-1:0] result;
        
        result[0] = 1'b0 ^ data[0];
        for(int i = 1; i < WIDTH_REQ; i++) begin
            result[i] = data[i] ^ data[i-1];
        end

        return result;
    endfunction

    logic [WIDTH_REQ-1:0] mpe, mpe_mask;
    logic [WIDTH_REQ-1:0] mpe_mux;
    logic [WIDTH_REQ-1:0] hptr, hptr_next;
    logic [WIDTH_REQ-1:0] request;
    logic [WIDTH_REQ-1:0] gnt_next;

    genvar i;

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            LOGIC            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    generate
        for(i = 0; i < WIDTH_REQ; i++) begin:gen_req
            always_ff @ (posedge clk or negedge reset_n) begin
                if(!reset_n) begin
                    request[i]      <= 1'b0;
                    req_rdy_o[i]    <= 1'b1;
                end
                else begin
                    if(req_i[i] && req_rdy_o[i]) begin
                        request[i]      <= 1'b1;
                        req_rdy_o[i]    <= 1'b0;
                    end
                    else if(gnt_next[i] && gnt_rdy_i) begin
                        request[i]      <= 1'b0;
                        req_rdy_o[i]    <= 1'b1;
                    end
                end
            end
        end
    endgenerate
    
    assign mpe_mask = bin2thermo(request & hptr);
    assign mpe = bin2thermo(request);

    assign mpe_mux = mpe_mask[WIDTH_REQ-1] ? mpe_mask : mpe;
    assign gnt_next = get_gnt(mpe_mux);


//обновление указателя
    assign hptr_next = (mpe[WIDTH_REQ-1] & gnt_rdy_i) ? {mpe_mux[WIDTH_REQ-2:0], 1'b0} : hptr;

    always_ff @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            hptr <= {WIDTH_REQ{1'b0}};
        end
        else begin
            hptr <= hptr_next;
        end
    end

//защелкивание выходного gnt'а в регистр
always_ff @ (posedge clk or negedge reset_n) begin
    if(!reset_n) gnt_o <= {WIDTH_REQ{1'b0}};
    else if(gnt_rdy_i) gnt_o <= gnt_next;
end
    
endmodule