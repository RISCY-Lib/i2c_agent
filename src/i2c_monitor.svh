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
// Description: The UVM Monitor for the UVM I2C Agent
//==============================================================================

class i2c_monitor extends uvm_component;
    `uvm_component_utils(i2c_monitor)

    // Virtual interface
    local virtual i2c_monitor_bfm m_bfm;

    //----------------------------------------------------------------------
    // Data Members
    //----------------------------------------------------------------------
    i2c_agent_config m_cfg;

    //----------------------------------------------------------------------
    // Component members
    //----------------------------------------------------------------------
    uvm_analysis_port #(i2c_seq_item) ap;

    //----------------------------------------------------------------------
    // Methods
    //----------------------------------------------------------------------

    // Standard UVM Methods
    function new(string name = "i2c_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        `get_config(i2c_agent_config, m_cfg, "i2c_agent_config")
        m_bfm = m_cfg.mon_bfm;
        m_bfm.proxy = this;
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            m_bfm.mon_i2c();
        end
    endtask

    function void notify_transaction(i2c_seq_item item);
        ap.write(item);
    endfunction

endclass: i2c_monitor
