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
// Description: The UVM Driver for the UVM I2C Agent
//==============================================================================

class i2c_driver extends uvm_driver #(i2c_seq_item);
    `uvm_component_utils(i2c_driver)

    //------------------------------------------------------------------------------
    // Member Variables
    //---------------------------------------------------------------------------
    // Virtual interface
    local virtual i2c_driver_bfm m_bfm;

    // Agent config
    i2c_agent_config m_cfg;

    // Sequence item
    i2c_seq_item i2c_frame;

    //------------------------------------------------------------------------------
    // Methods
    //---------------------------------------------------------------------------

    // Standard UVM Methods
    function new(string name = "i2c_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `get_config(i2c_agent_config, m_cfg, "i2c_agent_config")
        m_bfm = m_cfg.drv_bfm;
        m_bfm.m_cfg = m_cfg;
    endfunction

    task run_phase(uvm_phase phase);
        m_bfm.i2c_init();

        forever begin
            seq_item_port.get_next_item(i2c_frame);
            m_bfm.drive(i2c_frame);
            seq_item_port.item_done();
        end
    endtask

endclass : i2c_driver