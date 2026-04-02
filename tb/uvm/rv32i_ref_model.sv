class rv32i_ref_model extends uvm_object;
  `uvm_object_utils(rv32i_ref_model)

  logic [31:0] rf   [32];
  logic [31:0] dmem [64];
  logic [31:0] imem [64];
  logic [31:0] pc;

  function new(string name = "rv32i_ref_model");
    super.new(name);
    this.reset();
  endfunction

  function void reset();
    pc = 0;
    for (int i = 0; i < 32; i++) rf[i] = 0;
    for (int i = 0; i < 64; i++) begin
      dmem[i] = 0;
      imem[i] = 32'h00000013;
    end
  endfunction

  function void load_program(rv32i_seq_item item);
    for (int i = 0; i < item.instrs.size(); i++) imem[i] = item.instrs[i].encode();
  endfunction

  function int step(output logic [4:0] rd, output logic [31:0] wr_data);
    logic [31:0] instr;
    instr = imem[pc >> 2];
    // FINISH ME: Implement reference model execution logic here

    rd = 5'b0;
    wr_data = 32'b0;
    return 0; // return 1 for writes, 0 otherwise
  endfunction

endclass