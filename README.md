# NW-Tools
Small DOS tools to check the IPX protocal / Netware client status.

A collection of simple DOS programs to check the status of loaded IPX drivers and the NetWare client (NETX/VLM), mainly for use in batch files.

1. LSLTEST: detect if the Link Support Layer (LSL) is loaded.
   Errorlevel is 1, if LSL.COM is loaded.
   Errorlevel is 0, if LSL.COM is not loaded.
   Command-line arguments (optional):
     -h : Display the help screen
     -q : Quiet: No output at all, only errorlevel

2. IPXTEST: detect if the IPX protocol is loaded.
   Errorlevel is 1, if IPX is loaded.
   Errorlevel is 0, if IPX is not loaded.
   Command-line arguments (optional):
     -h : Display the help screen
     -q : Quiet: No output at all, only errorlevel

3. NETXTEST: detect if the NetWare Shell 2.x/3.x (NETX) is loaded.
   Errorlevel is 1, if NETX is loaded.
   Errorlevel is 0, if NETX is not loaded.
   Command-line arguments (optional):
     -h : Display the help screen
     -q : Quiet: No output at all, only errorlevel

4. VLMTEST: detect if Novell NetWare 4.x DOS Requester (VLM) is loaded.
   Errorlevel is 1, if VLM is loaded.
   Errorlevel is 0, if VLM is not loaded.
   Command-line arguments (optional):
     -h : Display the help screen
     -q : Quiet: No output at all, only errorlevel
This program does not search for the NetWare Shell 3.x (NETx), use NETXTEST for this task.

