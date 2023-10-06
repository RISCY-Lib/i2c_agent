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

    typedef enum {
        IDLE,
        START,
        ADDRESS,
        DIR,
        ACK,
        WRITE_DATA,
        READ_DATA,
        STOP
    } i2c_drv_state_e;

    i2c_drv_state_e drv_state;

    //----------------------------------------------------------------------
    // i2c Driving interface
    //----------------------------------------------------------------------

    // Initialize the BFM
    task i2c_init();
        i2c.scl = m_cfg.high;
        i2c.sda = m_cfg.high;

        drv_state = IDLE;
    endtask

    // Driver a i2c sequence item
    task drive(i2c_seq_item i2c_item);
        i2c_data_package data_pkg = null;

        while (i2c_item.data_pkgs.size() > 0) begin
            drv_state = START;

            if (data_pkg == null)
                start_condition();
            else
                restart_condition();

            data_pkg = i2c_item.data_pkgs.pop_front();

            drv_state = ADDRESS;

            drive_address(m_cfg.address, m_cfg.addr_bits);

            drv_state = DIR;

            drive_dir(data_pkg.dir);

            drv_state = ACK;

            drive_ack();

            if (data_pkg.dir == I2C_WRITE) begin
                drv_state = WRITE_DATA;
                drive_write_data(data_pkg.data);
            end
            else begin
                drv_state = READ_DATA;
                drive_read_data(data_pkg.data, i2c_item.final_ack_on_read);
            end
        end

        drv_state = STOP;

        stop_condition();

        drv_state = IDLE;
    endtask

    task start_condition();
        i2c.sda = m_cfg.high;
        i2c.scl = m_cfg.high;

        #(m_cfg.timing.bus_free);
        i2c.sda = m_cfg.low;

        #(m_cfg.timing.start_hold);
        i2c.scl = m_cfg.low;
    endtask

    task restart_condition();
        if (i2c.sda !== m_cfg.high)
            i2c.sda = m_cfg.high;

        if (i2c.scl !== m_cfg.high) begin
            #(m_cfg.timing.data_valid);
            i2c.scl = m_cfg.high;
        end

        #(m_cfg.timing.start_setup);
        i2c.sda = m_cfg.low;

        #(m_cfg.timing.start_hold);
        i2c.scl = m_cfg.low;
    endtask

    task stop_condition();
        if (i2c.sda !== m_cfg.low)
            i2c.sda = m_cfg.low;

        #(m_cfg.timing.low_period);
        i2c.scl = m_cfg.high;

        #(m_cfg.timing.stop_setup);
        i2c.sda = m_cfg.high;
    endtask

    task drive_bit(logic val);
        #(m_cfg.timing.low_period - m_cfg.timing.data_setup)
        if (val === 1'b1)
            i2c.sda = m_cfg.high;
        else if (val === 1'b0)
            i2c.sda = m_cfg.low;
        else
            i2c.sda = val;

        #(m_cfg.timing.data_setup);
        i2c.scl = m_cfg.high;

        #(m_cfg.timing.high_period);
        i2c.scl = m_cfg.low;
    endtask

    task drive_address(logic [9:0] addr, i2c_addr_size_e size);
        int len = 7;

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

            drv_state = WRITE_DATA;

            for (int idx = 7; idx >= 0; idx--) begin
                drive_bit(dbyte[idx]);
            end

            drv_state = ACK;

            drive_ack(1'bZ);
        end
    endtask

    task drive_read_data(logic [7:0] data[$], i2c_ack_e final_ack);
        logic [7:0] dbyte;

        while (data.size() > 0) begin
            dbyte = data.pop_front();

            drv_state = WRITE_DATA;

            for (int idx = 7; idx >= 0; idx--) begin
                drive_bit(1'bZ);
            end

            drv_state = ACK;

            // Ack
            if (data.size() == 0)
                drive_ack(final_ack);
            else
                drive_ack(I2C_ACK);
        end
    endtask

    task drive_ack(logic val=1'bZ);
        #(m_cfg.timing.data_ack);
        i2c.sda = val;

        #(m_cfg.timing.low_period - m_cfg.timing.data_ack);
        i2c.scl = m_cfg.high;

        #(m_cfg.timing.high_period);
        i2c.scl = m_cfg.low;
    endtask

endinterface