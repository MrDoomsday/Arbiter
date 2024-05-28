`include "interface.sv"
`include "etalon_design.sv"

module tc_ppa_arbiter_tb();


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************           DECLARATION       ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    localparam WIDTH_REQ = 7;
    localparam size_test = 1000_000;//число суммарных транзакций
    

    bit     clk;
    bit     reset_n;

    interface_req #(.WIDTH_REQ(WIDTH_REQ)) intf_req(clk, reset_n);
    interface_gnt #(.WIDTH_REQ(WIDTH_REQ)) intf_gnt(clk, reset_n);

    mailbox mbx_req_gen2drv [WIDTH_REQ-1:0];
    mailbox mbx_gnt_mon2scb, mbx_egnt_mon2scb;//etalon gnt
    int cnt_vld_request;//для подсчета действительного числа сгенерированных request'ов
    etalon_design #(.WIDTH_REQ(WIDTH_REQ)) edesign;//edesign - etalon design

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            INSTANCE         ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    tc_ppa_arbiter #(
        .WIDTH_REQ(WIDTH_REQ)
    ) DUT (
        .clk        (clk),
        .reset_n    (reset_n),
    
        .req_i      (intf_req.req),
        .req_rdy_o  (intf_req.rdy),

        .gnt_o      (intf_gnt.gnt),
        .gnt_rdy_i  (intf_gnt.rdy)
    );
    

    always begin
        clk <= 1'b0;
        #10;
        clk <= 1'b1;
        #10;
    end

/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            TASKS            ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/
    task wait_timeout(int tout);
        repeat(tout) @(posedge clk);
        $stop("TIMEOUT");
    endtask

    task gen_reset();
        reset_n <= 1'b0;
        repeat(10) @(posedge clk);
        reset_n <= 1'b1;
    endtask

    task gen_reset_req();
        intf_req.req <= {WIDTH_REQ{1'b0}};
    endtask

    task gen_reset_gnt();
        intf_gnt.rdy <= 1'b0;
    endtask



    task generate_request();
        bit rand_req;
        cnt_vld_request = 0;

        for(int i = 0; i < size_test; i++) begin
            for(int j = 0; j < WIDTH_REQ; j++) begin
                void'(std::randomize(rand_req) with {
                    rand_req dist {1:=1, 0:=9};//1/10 vs 9/10
                });

                if(rand_req) cnt_vld_request++;
                mbx_req_gen2drv[j].put(rand_req);
            end
        end
        $display("Number of valid requests", cnt_vld_request);
    endtask


    task automatic drive_req_item(int index_port);
        bit drv_req;

        forever begin
            mbx_req_gen2drv[index_port].get(drv_req);
            do begin
                intf_req.req[index_port] <= drv_req;
                @(posedge clk);
            end
            while(!intf_req.rdy[index_port]);
            intf_req.req[index_port] <= 1'b0;
        end
    endtask

    task drive_req();
        for(int i = 0; i < WIDTH_REQ; i++) begin
            fork
                automatic int k = i;            
                drive_req_item(k);
            join_none
        end
    endtask


    task drive_gnt();
        intf_gnt.rdy <= 1'b0;
        forever begin
            intf_gnt.rdy <= 1'b0;
            repeat($urandom_range(2,0)) @(posedge clk);
            intf_gnt.rdy <= 1'b1;
            repeat($urandom_range(2,0)) @(posedge clk);
        end
    endtask

    task monitor_gnt();
        forever begin
            @(posedge clk);
            if((intf_gnt.gnt > 0) && intf_gnt.rdy) begin
                mbx_gnt_mon2scb.put(intf_gnt.gnt);//один бит всегда активен
            end
        end
    endtask

    task check();
        logic [WIDTH_REQ-1:0] gnt, egnt;//egnt - etalon gnt
        int cnt_transaction;
        int cnt_fail_transaction;

        cnt_transaction = 0;
        cnt_fail_transaction = 0;

        forever begin
            mbx_egnt_mon2scb.get(egnt);
            mbx_gnt_mon2scb.get(gnt);

            if(egnt != gnt) begin
                $display("Etalog grant =%0b don't match grant %0b, time = %0d", egnt, gnt, $time);
                cnt_fail_transaction++;
            end

            cnt_transaction++;
            if(cnt_transaction >= cnt_vld_request) begin
                if(cnt_fail_transaction > 0) begin
                    $display("********Test FAILED********");
                    $display("Number of errors = %0d", cnt_fail_transaction);
                end
                else begin
                    $display("********Test PASSED********");
                    $display("Processed %0d requests", cnt_vld_request);
                end
                $stop();
            end
        end
    endtask


/***********************************************************************************************************************/
/***********************************************************************************************************************/
/*******************************************            TEST             ***********************************************/
/***********************************************************************************************************************/
/***********************************************************************************************************************/

    initial begin
    //создание экземпляров
        for(int i = 0; i < WIDTH_REQ; i++) begin
            mbx_req_gen2drv[i] = new();
        end
        mbx_gnt_mon2scb = new();
        mbx_egnt_mon2scb = new();
        edesign = new();

    //подключение эталонного дизайна
        edesign.vif_req = intf_req;
        edesign.vif_gnt = intf_gnt;
        edesign.mbx_gnt = mbx_egnt_mon2scb;


    //запуск сценария
        fork//сбрасываем всё
            gen_reset();
            gen_reset_req();
            gen_reset_gnt();
        join

        fork
            //request
            generate_request();
            drive_req();

            //etalon
            edesign.run();

            //grant
            drive_gnt();
            monitor_gnt();

            //checker
            check();

            wait_timeout(1000_000_000);//many cycles
        join

        repeat(100) @(posedge clk);
        $display("********TEST FINISHED********");
        $stop();
    end


endmodule