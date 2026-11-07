// instantiate SPRAM block
// do this for every block needed (up to 4)

// AD: address [13:0], address the location to be written and read, default is 0
// DI: data in [15:0]
// MASKWE: maskable write enable [3:0], when in write signal you can selectively write to individual I/O, default if 4'b1111
// WE: write enable input [0:0], 1'b1 for write, 1'b0 for read
// CS: memory enable input [0:0], 1'b1 to read/write, 1'b0 to disable
// CK: clock input [0:0]
// STDBY: light sleep input [0:0], 1'b0 for no change in output
// SLEEP: deep sleep input [0:0], shuts down power but retains memory, outputs of memory are all low
// PWROFF_N: power off input [0:0], shut down power without retaining anything
// DO: data output bus [15:0]

//write to the one before we are currently reading (prevent race conditions)

SP256K spram1(
 .DI(DATAIN),
 .AD(ADDRESS),
 .MASKWE(MASKWREN),
 .WE(WREN),
 .CS(CHIPSELECT),
 .CK(CLOCK),
 .STDBY(STANDBY),
 .SLEEP(SLEEP),
 .PWROFF_N(POWEROFF),
 .DO(DATAOUT_A)
);

