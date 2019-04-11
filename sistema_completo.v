// Design: Multiplicador secuencial
// Description: Perifericos y modulo top del diseño
// Author: Enrique Ostua <ostua@dte.us.es>, Paulino Ruiz de Clavijo Vázquez <paulino@dte.us.es>
// Modified by: Sergio Martín Guillén
// Copyright Universidad de Sevilla, Spain
// Rev: 2, marzo 2013

// Usando `default_nettype none, el compilador no supone, por defecto, que las entradas
// y las salidas de los módulos son de tipo 'wire'. Obliga a declararlas 'wire' expresamente.
// Además, gracias a esto, nos dará un error siempre que estemos usando un
// cable no declarado previamente, en vez de suponer una declaración implícita.
`default_nettype none




//         0        Los segmentos de la placa BASYS2 son activos en bajo
//        ---
//     5 |   | 1
//        ---   <- 6
//     4 |   | 2
//        ---
//         3


module conv_hex_a_7seg(
  input  wire [3:0] d,    // digito hexadecimal
  output reg  [6:0] seg   // Los 7 segmentos
  );

  always @*
  begin
  case (d)
      4'h0:    seg = 7'b1000000; //--0
      4'h1:    seg = 7'b1111001; //--1
      4'h2:    seg = 7'b0100100; //--2
      4'h3:    seg = 7'b0110000; //--3
      4'h4:    seg = 7'b0011001; //--4
      4'h5:    seg = 7'b0010010; //--5
      4'h6:    seg = 7'b0000010; //--6
      4'h7:    seg = 7'b1111000; //--7
      4'h8:    seg = 7'b0000000; //--8
      4'h9:    seg = 7'b0010000; //--9
      4'hA:    seg = 7'b0001000; //--A
      4'hB:    seg = 7'b0000011; //--b
      4'hC:    seg = 7'b1000110; //--C
      4'hD:    seg = 7'b0100001; //--d
      4'hE:    seg = 7'b0000110; //--E
      default: seg = 7'b0001110; //--F
    endcase
  end
endmodule  // sseg

// Modulo de refresco del display de 4 digitos.
// El reloj hay que conectarlo al de la placa a 50 Mhz.
// El digito3 es el de más a la izquierda y digito4 el de más a la derecha.
module controlador_display(
  input  wire clk,               // Reloj para el refresco
  input  wire [3:0] d3,d2,d1,d0, // 4 digitos de entrada
  output wire [6:0] cat,         // Catodos de los segmentos de salida
  output wire dp,                // Punto Decimal
  output reg [3:0] an            // Anodos de los segmentos. Cada display tiene un ánodo común.
  );

  reg [15:0] displcounter=0;   // Divisor de frecuencia
  reg [3:0] digito_hex;        // Numero hexadecimal

  assign dp = 1'b1; // Punto decimal: 0 ON, 1 OFF

  always @(posedge clk)
   begin
     displcounter = displcounter + 1;
   end

  always @(displcounter,d0,d1,d2,d3)
  begin
    case ({displcounter[15],displcounter[14]})
      2'b00:    begin digito_hex = d0; an = 4'b1110; end
      2'b01:    begin digito_hex = d1; an = 4'b1101; end
      2'b10:    begin digito_hex = d2; an = 4'b1011; end
      default:  begin digito_hex = d3; an = 4'b0111; end
    endcase
  end
  // Instancia del convertidor
   conv_hex_a_7seg INST_convertidor(digito_hex, cat);
endmodule // display_controller




// Controla los LEDS para que cambien informando al usuario.
module controlador_leds(
  input  wire botonclk,
  input  wire fin,
  input  wire botonreset,
  input  wire botonxs,
  output reg  [7:0] led
  );

  // botonreset borra todos los LEDS.
  // fin hace que se activen todos los LEDS.
  // botonclk hace que se rote hacia la derecha,
  // salvo si botonxs esta activado, en cuyo caso
  // se enciende un único LED.

  always@(posedge botonclk,posedge fin,posedge botonreset)
  begin
    if(botonreset)
      led <= 8'b00000000;     // 'RESET' asíncrono de los LEDS
    else if(fin)
      led <= 8'b11111111;     // 'PRESET' asícrono de los LEDS
    else if(botonxs)
      led <= 8'b10000000;     // Si llega reloj cuando XS es 1, inicializo 1 solo LED.
    else
      led <= {led[0],led[7:1]};  // Si llega reloj en otro caso, rotación de los LEDS.
  end
endmodule




// El módulo sietsma_completo es el TOP MODULE que vamos a 'volcar' sobre el chip FPGA,
// por lo que hay que conectar sus entradas y salidas a los PINES externos de la FPGA.
// El fichero BASYS2.UCF contiene la declaración de dichas conexiones.
// Los pines de la FPGA están conectados a diverso hardware que hay instalado en la placa BASYS2,
// como son pulsadores, LEDS, interruptores, displays de 7 segmentos, etc.
// Hay un PIN de la FPGA que recibe desde la placa BASYS2 una señal de reloj de 50 MHz.
module sistema_completo(
  input  wire  clk,               // Conectado al reloj MCLK de la placa BASYS2, a 50 MHz.
  input  wire  botonclk,          // Conectado al botón BTN0 de la placa BASYS2 (simula reloj).
  input  wire  botonreset,        // Conectado al botón BTN1 de la placa BASYS2 (simula reset).
  input  wire  botonxs,           // Conectado al botón BTN2 de la placa BASYS2 (simula xs).
  input  wire  [3:0] num_A_en_SW, // Conectado directamente a 4 switches (SW7, SW6, SW5 y SW4) de la placa BASYS2.
  input  wire  [3:0] num_B_en_SW, // Conectado directamente a 4 switches (SW3, SW2, SW1 y SW0) de la placa BASYS2.
  output wire  [6:0] catodo,      // Conectado a los cátodos de los 7 segmentos de los displays (CA7, CA6, ..., CA1) de la placa BASYS2.
  output wire  puntodec,          // Conectado al cátodo del Punto Decimal del display (DP) de la placa BASYS2.
  output wire [3:0] anodo,        // Conectado a los ánodos de los 4 displays (AN3, AN2, AN1, AN0) de la placa BASYS2.
  output wire [7:0] led           // Conectado a los LEDS (LD8, LD7, ..., LD0) de la placa BASYS2.
   );

  wire [7:0] mult; // Bus interno conectado a la salida 'mult' del multiplicador
  wire cable_fin;  // Cable para hacer llegar el 'fin' al controlador de LEDS.

  controlador_display INST_contr_display (
    .clk(clk),
    .d3(num_A_en_SW),   // Dígito de la izquierda del todo.
    .d2(num_B_en_SW),
    .d1(mult[7:4]),
    .d0(mult[3:0]),     // Digito de la serecha del todo.
    .cat(catodo),
    .dp(puntodec),      // El punto decimal
    .an(anodo)
    );


  multiplicador INST_multiplicador(
    .clk(botonclk),
    .a(num_A_en_SW),
    .b(num_B_en_SW),
    .xs(botonxs),
    .reset(botonreset),
    .fin(cable_fin),
    .mult(mult));


  controlador_leds INST_contr_leds (
    .botonclk(botonclk),
    .fin(cable_fin),
    .botonreset(botonreset),
    .botonxs(botonxs),
    .led(led)
    );

endmodule
