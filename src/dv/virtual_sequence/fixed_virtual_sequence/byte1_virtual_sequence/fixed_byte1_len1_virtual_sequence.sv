class fixed_byte1_len1_virtual_sequence extends axi_fifo_virtual_base_sequence;

  `uvm_object_utils(fixed_byte1_len1_virtual_sequence)
  `uvm_declare_p_sequencer(axi_fifo_virtual_sequencer)

  fixed_byte1_len1_sequence seq;
  response_id_0_slave_seq axi_seq;

  function new(string name = "fixed_byte1_len1_virtual_sequence");
    super.new(name);
  endfunction

  virtual task body();

    fork
      begin
        seq = fixed_byte1_len1_sequence::type_id::create("fixed_byte1_len1_sequence");
        seq.start(p_sequencer.cpu_seqr_h); 
      end

      begin
        axi_seq = response_id_0_slave_seq::type_id::create("response_id_0_slave_write_seq");
        axi_seq.start(p_sequencer.axi_slave_wr_seqr); 
      end

      begin
        axi_seq = response_id_0_slave_seq::type_id::create("response_id_0_slave_read_seq");
        axi_seq.start(p_sequencer.axi_slave_rd_seqr); 
      end

    join_any
    wait fork;

  endtask 
endclass
