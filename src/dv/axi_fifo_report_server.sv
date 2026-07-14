class axi_fifo_report_server extends uvm_report_server;

  `uvm_object_utils(axi_fifo_report_server)

  localparam string RED     = "\033[1;31m";
  localparam string GREEN   = "\033[1;32m";
  localparam string YELLOW  = "\033[1;33m";
  localparam string BLUE    = "\033[1;34m";
  localparam string MAGENTA = "\033[1;35m";
  localparam string CYAN    = "\033[1;36m";
  localparam string RESET   = "\033[0m";

  function new(string name = "axi_fifo_report_server");
    super.new();
  endfunction

  virtual function string compose_message( uvm_severity severity, string name, string id, string message, string filename, int line );

    string sev_color, sev_label,composed;

    case(severity)
      UVM_INFO:    begin sev_color = GREEN;   sev_label = "[INFO]";  end
      UVM_WARNING: begin sev_color = YELLOW;  sev_label = "[WARN]";  end
      UVM_ERROR:   begin sev_color = RED;     sev_label = "[ERROR]"; end
      UVM_FATAL:   begin sev_color = MAGENTA; sev_label = "[FATAL]"; end
      default:     begin sev_color = RESET;   sev_label = "[MSG]";   end
    endcase

    composed = $sformatf("%s%-5s%s %s(ID=%-18s)%s %s[time = %0t]%s %s", sev_color, sev_label, RESET, CYAN, id, RESET, BLUE, $time, RESET, message);
    return composed;
  endfunction

endclass

