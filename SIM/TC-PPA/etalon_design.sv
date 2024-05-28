class etalon_design #(
    parameter int WIDTH_REQ = 8
);

    virtual interface_req #(.WIDTH_REQ(WIDTH_REQ)) vif_req;
    virtual interface_gnt #(.WIDTH_REQ(WIDTH_REQ)) vif_gnt;

    mailbox mbx_gnt;

    logic [WIDTH_REQ-1:0] request;
    

    function new();
    endfunction

    virtual task run();
        wait(vif_req.reset_n);

        fork
            load_request();
            handler_request();
        join
    endtask

    virtual task load_request();
        request <= {WIDTH_REQ{1'b0}};

        forever begin
            @(posedge vif_req.clk);
            for(int i = 0; i < WIDTH_REQ; i++) begin
                if(vif_req.req[i] && vif_req.rdy[i]) begin
                    request[i] <= 1'b1;
                end
            end
        end
    endtask

    virtual task handler_request();
        int point, point_new;
        bit req_ok;//сигнализирует, что на данный запрос мы уже отправили подтверждение

        point = 0;
        point_new = 0;

        forever begin
            req_ok = 0;
            @(posedge vif_gnt.clk);
            if(/*(vif_gnt.gnt > 0) && */vif_gnt.rdy) begin
                for(int i = point; i < WIDTH_REQ; i++) begin
                    if(request[i]) begin
                        request[i] = 1'b0;
                        req_ok = 1'b1;
                        mbx_gnt.put((1 << i));
                        point_new = (i+1)%WIDTH_REQ;
                        break;//дальше смысла анализировать массив нет
                    end
                end

                if(!req_ok) begin//если на предыдущем этапе ничего найдено не было ищем в массиве сначала
                    for(int i = 0; i < point; i++) begin
                        if(request[i]) begin
                            request[i] = 1'b0;
                            mbx_gnt.put((1 << i));
                            point_new = (i+1)%WIDTH_REQ;
                            break;
                        end
                    end
                end
            end
            point = point_new;
        end
    endtask

endclass