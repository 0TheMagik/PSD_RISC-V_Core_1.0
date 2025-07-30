# Implementasi Instruction Set Architecture RISC-V RV32I

## Abstrak



## Metode

## Dokumentasi

## Masalah Implementasi

#### 1. Menghentikan Berjalannya Instruksi
Saat Processor berjalan setiap instruksi melewati sebuah tahapan, namun instruksi tertentu memerlukan berjalannya tahapan dihentikan untuk menghindari kesalahan dalam menjalankan program. Untuk mengatasinya Processor dapat menghentikan Pipeline ke seluruh tahapan dengan sebuah Signal `en` yang di pasangkan dengan `clk`. 


```vhdl
    clk_ctrl <= clk_state AND en;
    load_ctrl <= load_state AND en;

    RegFile_inst: RegFile 
    port map(
        clk             => clk_state,
        load            => load_ctrl,
        rst             => rst_state,
        addr_read_0     => decode_regfile_0,
        addr_read_1     => decode_regfile_1,
        addr_write_0    => decode_regfile_dst,
        data_in         => reg_data_write_0,
        data_out_0      => reg_file_out_0,
        data_out_1      => reg_file_out_1
    );


    Decoder_inst: Decoder 
    port map(
        clk             => clk_state,
        rst             => rst_state,
        instruction     => instruction,
        opcode          => open,
        reg_address_0   => decode_regfile_0,
        reg_address_1   => decode_regfile_1,
        reg_address_dst => decode_regfile_dst,
        immediate       => immediate,
        alu_op          => open,
        mux2_1_sel      => open
    );
```
cuplikan kode pada tahapan Decode

Seluruh komponen yang digunakan pada implementasi menggunakan Asynchronus reset Clocked process sehingga agar proses dapat berjalan maka clock harus sampai ke komponen tersebut. Dengan menghentikan clock sebelum sampai ke komponen dengan signal `en` maka tidak ada process yang berjalan sehingga pipeline dapat dihentikan.