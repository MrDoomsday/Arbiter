interface interface_req #(
    parameter int WIDTH_REQ = 8
) (input bit clk, input bit reset_n);

    logic [WIDTH_REQ-1:0] req;
    logic [WIDTH_REQ-1:0] rdy;



// ASSERTION
    generate
        for(genvar i = 0; i < WIDTH_REQ; i++) begin:sva_gen_req
            SVA_CHECK_STABLE_REQUEST: assert property (
                @(posedge clk) disable iff(!reset_n)
                req[i] & ~rdy[i] |-> ##1 req[i]
            ) else $error("SVA error: request is not stable for ready is zero");
        end
    endgenerate

    SVA_CHECK_UNKNOWN: assert property (
        @(posedge clk) disable iff(!reset_n)
        ~$isunknown({req, rdy})
    ) else $error("SVA error: request or ready is unknown");

endinterface


interface interface_gnt #(
    parameter int WIDTH_REQ = 8
) (input bit clk, input bit reset_n);

    logic [WIDTH_REQ-1:0]   gnt;
    logic                   rdy;



// ASSERTION
    SVA_CHECK_STABLE_GRANT: assert property (
        @(posedge clk) disable iff(!reset_n)
        ~rdy |-> ##1 $stable(gnt)
    ) else $error("SVA error: grant is not stable for ready is zero");


    SVA_CHECK_UNKNOWN: assert property (
        @(posedge clk) disable iff(!reset_n)
        ~$isunknown({gnt, rdy})
    ) else $error("SVA error: grant or ready is unknown");

endinterface