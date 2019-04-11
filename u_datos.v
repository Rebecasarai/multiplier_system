// Design: Multiplicador secuencial
// Description: Multiplicador secuencial - Unidad de datos
// Author: Paulino Ruiz de Clavijo Vázquez <paulino@dte.us.es>
// Modified by: Sergio Martín Guillén
// Copyright Universidad de Sevilla, Spain
// Rev: 2, marzo 2013

// Usando `default_nettype none, el compilador no supone, por defecto, que las entradas
// y las salidas de los módulos son de tipo 'wire'. Obliga a declararlas 'wire' expresamente.
// Además, gracias a esto, nos dará un error siempre que estemos usando un
// cable no declarado previamente, en vez de suponer una declaración implícita.
`default_nettype none


// Registro A
module reg_a (
  input  wire clk,cl,w,
  input  wire [3:0] din,
  output reg  [3:0] dout
  );
 always@(posedge clk)
   if(w)
     dout <= din;
   else if(cl)
     dout <= 0;
endmodule


// Registro C
module reg_c (
  input  wire clk,cl,w,
  input  wire din,
  output reg  dout
  );

  always@(posedge clk)
   if(w)
     dout <= din;
   else if(cl)
     dout <= 0;
endmodule


// Sumador de 4 bits
module sumador_4(
 input  wire [3:0] a,
 input  wire [3:0] b,
 output wire [3:0] res,
 output wire cout
 );
 assign {cout,res} = a + b;
endmodule


// Contador modulo 4
module cont_mod_4(
  input  wire clk,cl,up,
  output wire cy
  );
  reg [1:0] q;
  assign cy = &q;
  always@(posedge clk)
    if(up)
      q <= q + 1;
    else if(cl)
      q <= 0;
endmodule


// Registro de desplazamiento
module reg_despl_4(
  input  wire clk,cl,shr,w,sri,
  input  wire [3:0] din,
  output reg  [3:0] dout);

  always@(posedge clk)
    if(shr)
      dout <= {sri,dout[3:1]};
    else if (w)
      dout <= din;
    else if(cl)
      dout <= 0;
endmodule


// Unidad de datos - Descripcion estructural
// Se instancian todos los componentes de la unidad
// de datos y se interconectan entre si
module u_datos(
  input  wire [3:0] datoA,
  input  wire [3:0] datoB,
  input  wire clk,wa,upcont,clinicio,
  input  wire wc,clc,wsumh,wsuml,shrsum,
  output wire [7:0] result,
  output wire cycont
  );

  wire [3:0] bus_out_A;
  wire [3:0] bus_out_SUMADOR;
  wire cable_cout, cable_out_C;

  // Instancia del registro A
  reg_a A(.din(datoA),.cl(1'b0),.clk(clk),.w(wa),.dout(bus_out_A));
  // Instancia del sumador
  sumador_4 SUMADOR(.a(result[7:4]),.b(bus_out_A),.res(bus_out_SUMADOR),.cout(cable_cout));
  // Instancia del registro de desplazamiento para SUMH
  reg_despl_4 SUMH(.din(bus_out_SUMADOR),.cl(clinicio),.w(wsumh),.clk(clk),
                   .shr(shrsum),.sri(cable_out_C),.dout(result[7:4]));
  // Otra instancia del registro de desplazamiento para SUML
  reg_despl_4 SUML(.din(datoB),.cl(1'b0),.w(wsuml),.clk(clk),
                   .shr(shrsum),.sri(result[4]),.dout(result[3:0]));
  // Instancia del registro C
  reg_c C(.din(cable_cout),.cl(clc),.clk(clk),.w(wc),.dout(cable_out_C));
  // Instancia del contador
  cont_mod_4 CONT(.clk(clk),.cl(clinicio),.cy(cycont),.up(upcont));
endmodule

