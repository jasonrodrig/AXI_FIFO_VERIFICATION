class axi_fifo_virtual_base_sequence extends uvm_sequence;

  `uvm_object_utils(axi_fifo_virtual_base_sequence)
  `uvm_declare_p_sequencer(axi_fifo_virtual_sequencer)

  cpu_base_sequence seq;
  axi_slave_bk_base_seq axi_seq;

  function new(string name = "axi_fifo_virtual_base_sequence");
    super.new(name);
  endfunction

  virtual task body();

    fork
      begin
        seq = cpu_base_sequence::type_id::create("write_seq");
        seq.start(p_sequencer.cpu_seqr_h); 
      end

      begin
        axi_seq = axi_slave_bk_base_seq::type_id::create("axi_seq");
        axi_seq.start(p_sequencer.axi_slave_wr_seqr); 
      end

    join_any

  endtask 
endclass
