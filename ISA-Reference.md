# Feather ISA Reference Sheet

## Instructions

### Data processing

31:28 | 27:26 | 25 | 24:21 | 20 | 19:16 | 15:12 | 11:0
:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:
`cond` | `op = 00` | `I` | `cmd` | `S` | `Rn` | `Rd` | `Src2`

If `S` is set, the `NZCV` flags are updated.

If `I` is set, `Src2` is an immediate value with the following format:

11:8 | 7:0
:---:|:---:
`rot` | `imm8`

The final value is `imm8 >> (2 * rot)`.

Otherwise, `Src2` can be a register `Rm` shifted by an immediate amount `shamt5`, encoded as:

11:7 | 6:5 | 4 | 3:0
:---:|:---:|:---:|:---:
`shamt5` | `sh` | `0` | `Rm`

or a register `Rm` shifted by another register `Rs`:

11:8 | 7 | 6:5 | 4 | 3:0
:---:|:---:|:---:|:---:|:---:
`Rs` | `0` | `sh` | `1` | `Rm`

### Memory instructions

31:28 | 27:26 | 25 | 24 | 23 | 22 | 21 | 20 | 19:16 | 15:12 | 11:0
:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:
`cond` | `op = 01` | `not(I)` | `P` | `U` | `B` | `W` | `L` | `Rn` | `Rd` | `Src2`

If `I` is set, `Src2` (the offset), is interpreted as a 12-bit immediate value.
Otherwise, `Src2` is interpreted as:

11:7 | 6:5 | 4 | 3:0
:---:|:---:|:---:|:---:
`shamt5` | `sh` | `1` | `Rm`

`L` distinguishes between load and store instructions. `U` controls whether the offset should be added or subtracted from `Rn`. `B` determines whether the instruction loads/stores an unsigned byte.

#### Indexing model control bits

P | W | Index mode
---|---|---
`0` | `0` | Post-index
`0` | `1` | Not supported
`1` | `0` | Offset
`1` | `1` | Pre-index

### Branch instructions

31:28 | 27:26 | 25:24 | 23:0
:---:|:---:|:---:|:---:
`cond` | `op = 10` | `1L` | `imm24`

`L` determines whether this is a branch and link instruction.
The branch target address (BTA) is given by:

`BTA <= (PC + 8) + (imm24 * 4)`
or with a shift
`BTA <= (PC + 8) + (imm24 << 2)`

where `imm24` is a signed integer.

## `sh` field encodings

Instruction | `sh` | Operation
---|:---:|---
`LSL` | `00` | Logical shift left
`LSR` | `01` | Logical shift right
`ASR` | `10` | Arithmetic shift right
`ROR` | `11` | Rotate right

## `cmd` field encodings

`cmd` | Mnemonic | Operation | Supported
---|---|---|---
`0000` | `AND` | `Rd <= Rn and Src2` | No
`0001` | `EOR` | `Rd <= Rn xor Src2` | No
`0010` | `SUB` | `Rd <= Rn - Src2` | No
`0011` | `RSB` | `Rd <= Src2 - Rn` | No
`0100` | `ADD` | `Rd <= Rn + Src2` | No
`0101` | `ADC` | `Rd <= Rn + Src2 + c` | No
`0110` | `SBC` | `Rd <= Rn - Src2 - not(c)` | No
`0111` | `RSC` | `Rd <= Src2 - Rn - not(c)` | No
`1000` | `TST` | Set flags for `Rn and Src2` | No
`1001` | `TEQ` | Set flags for `Rn xor Src2` | No
`1010` | `CMP` | Set flags for `Rn - Src2` | No
`1011` | `CMN` | Set flags for `Src2 - Rn` | No
`1100` | `ORR` | `Rd <= Rn or Src2` | No
`1101` | `MOV` | `Rd <= Src2` | No
`1110` | `BIC` | `Rd <= Rn and not(Src2)` | No
`1111` | `MVN` | `Rd <= not(Rn)` | No


## Condition Mnemonics

`cond` | Mnemonic | Name | Condition
---|---|---|---
`0000` | `EQ` | Equal | `z`
`0001` | `NE` | Not equal | `not(z)`
`0010` | `CS/HS` | Carry set/unsigned higher or same | `c`
`0011` | `CC/LO` | Carry clear/unsigned lower | `not(c)`
`0100` | `MI` | Minus/negative | `n`
`0101` | `PL` | Plus/positive or zero | `not(n)`
`0110` | `VS` | Overflow/overflow set | `v`
`0111` | `VC` | No overflow/overflow clear | `not(v)`
`1000` | `HI` | Unsigned higher | `not(z) and c`
`1001` | `LS` | Unsigned lower or same | `z or not(c)`
`1010` | `GE` | Signed greater than or equal | `not(n xor v)`
`1011` | `LT` | Signed less than | `n xor v`
`1100` | `GT` | Signed greater than | `not(z) and not(n xor v)`
`1101` | `LE` | Signed less than or equal | `z or (n xor v)`
`1110` | `AL` | Always/unconditional | `1`
