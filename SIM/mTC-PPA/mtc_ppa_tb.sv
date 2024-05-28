module mtc_ppa_tb();


    localparam WIDTH_N = 8;//размер входного вектора request
    localparam AMOUNT_M = 3;//максимальное число допустимых одновременных grant'ов

    logic                                   clk;
    logic                                   reset_n;

    logic     [WIDTH_N-1:0]                 req_i;
    logic                                   req_vld_i;
    logic                                   req_rdy_o;

    logic     [WIDTH_N-1:0]                 gnt_o;
    logic                                   gnt_vld_o;
    logic                                   gnt_rdy_i;





    mtc_ppa_top #(
        .WIDTH_N    (WIDTH_N),//размер входного вектора request
        .AMOUNT_M   (AMOUNT_M)//максимальное число допустимых одновременных grant'ов
    ) DUT (
        .clk        (clk),
        .reset_n    (reset_n),

        .req_i      (req_i),
        .req_vld_i  (req_vld_i),
        .req_rdy_o  (req_rdy_o),

        .gnt_o      (gnt_o),
        .gnt_vld_o  (gnt_vld_o),
        .gnt_rdy_i  (gnt_rdy_i)
    );


    always begin
        clk = 1'b0;
        #10;
        clk = 1'b1;
        #10;
    end


    task generate_reset();
        reset_n <= 1'b0;
        repeat(10) @(posedge clk);
        reset_n <= 1'b1;
    endtask


    initial begin
        req_i <= {WIDTH_N{1'b0}};
        req_vld_i <= 1'b0;
        generate_reset();

        req_i <= 8'b11111111;
        req_vld_i <= 1'b1;

        repeat(100) @ (posedge clk);
        $stop();
    end



endmodule