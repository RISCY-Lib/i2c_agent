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
// Description: The Driver BFM for the UVM I2C Agent
//==============================================================================

interface i2c_driver_bfm (
    i2c_if i2c
);

    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import i2c_agent_pkg::*;

    //----------------------------------------------------------------------
    // Members
    //----------------------------------------------------------------------
    // Config
    i2c_agent_config m_cfg;

    //----------------------------------------------------------------------
    // i2c Driving interface
    //----------------------------------------------------------------------

    // Initialize the BFM
    task i2c_init();
        i2c.scl = m_cfg.high;
        i2c.sda = m_cfg.high;
    endtask

    // Driver a i2c sequence item
    task drive(i2c_seq_item i2c_item);
        start_condition();

        drive_address(i2c_item.addr, i2c_item.addr_bits);

        drive_dir(i2c_item.dir);

        drive_ack();

        if (i2c_item.dir == I2C_WRITE) begin
            drive_write_data(i2c_item.data);
        end
        else begin
            drive_read_data(i2c_item.data_bytes);
        end

        stop_condition();
    endtask

    task start_condition();
        i2c.sda = m_cfg.high;
        i2c.scl = m_cfg.high;

        #(m_cfg.timing.start_setup);
        i2c.sda = m_cfg.low;

        #(m_cfg.timing.start_hold);
        i2c.scl = m_cfg.low;
    endtask

    task stop_condition();
        i2c.scl = m_cfg.high;

        #(m_cfg.timing.stop_setup);
        i2c.sda = m_cfg.high;
    endtask

    task drive_bit(logic val);
        #(m_cfg.timing.low_period - m_cfg.timing.data_setup)
        i2c.sda = (val) ? m_cfg.high : m_cfg.low;

        #(m_cfg.timing.data_setup);
        i2c.scl = m_cfg.high;

        #(m_cfg.timing.high_period);
        i2c.scl = m_cfg.low;
    endtask

    task drive_address(logic [9:0] addr, i2c_addr_size_e size);
        int len = (size == I2C_7_BIT_ADDR) ? 7 : 10;

        for (int i = len - 1; i >= 0; i--) begin
            drive_bit(addr[i]);
        end
    endtask

    task drive_dir(i2c_dir_e dir);
        drive_bit(dir);
    endtask

    task drive_write_data(logic [7:0] data[$]);
        logic [7:0] dbyte;

        while (data.size() > 0) begin
            dbyte = data.pop_front();

            for (int idx = 7; idx >= 0; idx--) begin
                drive_bit(dbyte[idx]);
            end

            drive_ack();
        end
    endtask

    task drive_read_data(int data_bytes);
        for (int i = 0; i < data_bytes; i++) begin
            for (int j = 0; j < 8; j++) begin
                drive_bit(1'bZ);
            end

            // Ack
            drive_bit(1'b1);
        end
    endtask

    task drive_ack();
        drive_bit(1'bZ);
    endtask

endinterface