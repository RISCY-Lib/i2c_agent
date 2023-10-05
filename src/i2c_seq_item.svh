//==============================================================================
// An I2C UVM Agent
// Copyright (C) 2023  RISCY-Lib Contributors
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; If not, see <https://www.gnu.org/licenses/>.
//==============================================================================

//==============================================================================
// Description: The Package for the UVM I2C Agent
//==============================================================================

`ifndef __I2C_SEQ_ITEM_SVH__
`define __I2C_SEQ_ITEM_SVH__

class i2c_data_package extends uvm_object;
    `uvm_object_utils(i2c_data_package)

    //----------------------------------------------------------------------
    // Data Members
    //----------------------------------------------------------------------
    i2c_dir_e dir;

    logic [7:0] data[$];

    //----------------------------------------------------------------------
    // Methods
    //----------------------------------------------------------------------

    // Standard UVM Methods:
    function new(string name = "i2c_seq_item");
        super.new(name);
    endfunction: new

    function void debug();
        int idx;

        `uvm_info("I2C_DATA_PACKAGE", $sformatf("Dir: %01d", dir), UVM_LOW)

        foreach (data[idx]) begin
            `uvm_info("I2C_DATA_PACKAGE", $sformatf("Data[%0d]=0x%02X", data[idx]), UVM_LOW)
        end
    endfunction

endclass


class i2c_seq_item extends uvm_sequence_item;
    `uvm_object_utils(i2c_seq_item)

    //----------------------------------------------------------------------
    // Data Members
    //----------------------------------------------------------------------

    i2c_addr_size_e addr_bits;

    rand logic [9:0] addr;

    i2c_data_package data_pkgs[$];

    i2c_ack_e final_ack_on_read = I2C_ACK;

    //----------------------------------------------------------------------
    // Methods
    //----------------------------------------------------------------------

    // Standard UVM Methods:
    function new(string name = "i2c_seq_item");
        super.new(name);
    endfunction: new

    function void do_copy(uvm_object rhs);
        i2c_seq_item to_copy;

        if (!$cast(to_copy, rhs))
            `uvm_fatal("do_copy", "cast failed, check type compatibility")

        super.do_copy(rhs);

        addr = to_copy.addr;
    endfunction: do_copy

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        i2c_seq_item to_compare;

        if (!$cast(to_compare, rhs)) begin
            `uvm_error("do_compare", "cast failed, check type compatibility")
            return 0;
        end

        return super.do_compare(rhs, comparer) && (addr == to_compare.addr);
    endfunction

    function string convert2string();
        string s;

        $sformat(s, "i2c_seq_item:\n\taddr = %0d", addr);

        return s;
    endfunction

    function void do_print(uvm_printer printer);
        printer.m_string = convert2string();
    endfunction

    function void do_record(uvm_recorder recorder);
        super.do_record(recorder);

        recorder.record_field_int("addr", addr, $bits(addr), UVM_DEC);
    endfunction

endclass

`endif  // __I2C_SEQ_ITEM_SVH__