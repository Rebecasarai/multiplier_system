// Design: Test bench - Multiplicador secuencial
// Description: Testbench para algunos casos
// Author: Paulino Ruiz de Clavijo Vázquez <paulino@dte.us.es>
// Modified by: Sergio Martín Guillén
// Copyright Universidad de Sevilla, Spain
// Rev: 2, marzo 2013

// Con esto no supone, por defecto, que las entradas y las salidas de
// los módulos son de tipo 'wire'. Obliga a declararlas 'wire' expresamente.
// Además, gracias a esto, nos dará un error siempre que estemos usando un
// cable no declarado previamente, en vez de suponer una declaración implícita.
`default_nettype none

`timescale 1ns / 1ps


// Modulo de testbench del módulo multiplicador
module TEST_multiplicador();

  wire [7:0] mult;  // Dato 'wire' del testbench conectado a la salida mult
  wire fin;         // Dato 'wire' del testbench conectado a la salida fin

  reg [3:0] a;      // Dato 'reg' del testbench conectado a la entrada a
  reg [3:0] b;      // Dato 'reg' del testbench conectado a la entrada b
  reg clk;          // Dato 'reg' del testbench conectado a la entrada clk
  reg xs;           // Dato 'reg' del testbench conectado a la entrada xs
  reg reset;        // Dato 'reg' del testbench conectado a la entrada reset

  reg [4:0] ciclo;  // Variable auxiliar para contar los ciclos (de 0 a 31)

  // Instancia del módulo a probar
  multiplicador INST_multiplicador(
    .a(a),
    .b(b),
    .clk(clk),
    .xs(xs),
    .reset(reset),
    .fin(fin),
    .mult(mult)
    );

  // Reloj de frecuencia 50 Mhz (periodo 20ns)
  always
    begin
      #10;
      clk = ~clk;
    end


  initial
    begin :bloque_initial

      // variables auxiliares que se usaran en el testbench.
      reg [4:0] i;           // indice para bucle (de 0 a 31)
      reg [3:0] a_vec[0:11]; // Vector de 12 elementos de prueba
      reg [3:0] b_vec[0:11]; // Vector de 12 elementos de prueba


      // Inicialización del array de valores del test
      // se puede leer desde un fichero de texto, pero
      // por no complicarlo más prefiero hacerlo asi.

      {a_vec[0],b_vec[0]}   = 8'b_1110_0101;  //  El ejemplo del manual de la practica
      {a_vec[1],b_vec[1]}   = 8'h23;  //  2 * 3
      {a_vec[2],b_vec[2]}   = 8'h32;  //  3 * 2
      {a_vec[3],b_vec[3]}   = 8'hAA;  // 10 * 10
      {a_vec[4],b_vec[4]}   = 8'hFF;  // 16 * 16
      {a_vec[5],b_vec[5]}   = 8'hA0;  // 10 * 0
      {a_vec[6],b_vec[6]}   = 8'h0A;  //  0 * 10
      {a_vec[7],b_vec[7]}   = 8'hB1;  // 11 * 1
      {a_vec[8],b_vec[8]}   = 8'h1B;  //  1 * 11
      {a_vec[9],b_vec[9]}   = 8'h2D;  //  2 * 13
      {a_vec[10],b_vec[10]} = 8'h22;  //  2 * 2
      {a_vec[11],b_vec[11]} = 8'h57;  //  5 * 7


      xs=0;
      clk=0;
      reset=1;
      // La unidad de control del multiplicador pasará
      // al estado S0 pues hemos activado el reset,
      // que es asíncrono y activo en nivel alto.

      @(negedge clk);   // Esperamos a estar en mitad de un ciclo.
      reset=0;          // Y desactivamos la señal de reset.

      @(posedge clk);   // Dejamos que pase un flanco de subida.

      // Vamos a entrar en un bucle que se repetira 12 veces.
      // En cada iteración haremos una multiplicación
      for(i=0;i<12;i=i+1)
        begin
          ciclo=0;    // En el ciclo 0 el estado debe ser S0.
          @(posedge clk);
          ciclo=1;    // En el ciclo 1 el estado debe ser S0. Activaremos xs.
          xs=1;       // Activo xs durante un ciclo completo.
          a=a_vec[i]; // Pongo datos en las entradas
          b=b_vec[i]; // a y b del multiplicador.

          @(posedge clk);
          ciclo=2;
          // Tras el flanco, en el ciclo 2, debemos estar en el estado S1
          xs=0;       // Desactivo xs

          // Vamos a esperar a la señal de fin o un máximo de 28 ciclos
          while ( ciclo<28 && fin==0 )
            begin
              @(posedge clk);
              ciclo = ciclo + 1;
            end

          if (ciclo==28)
            begin
              $display("ERROR. Al multiplicar %d x %d no se ha activado la señal de FIN.",a,b);
              $finish;
            end

          // Si llegamos aquí es porque estamos a mitad de un ciclo y
          // la salida fin está activada.
          @(posedge clk);
          // hemos dejado pasar un ciclo y el resultado debe
          // seguir estando en el bus de salida databus aunque
          // en este ciclo que ha pasado FIN debe valer 0.

          if((mult)!=a*b)
            begin
              $display("ERROR: El resultado de la multiplicacion %d x %d es incorrecto",a,b);
              $finish;
            end
       end // (del bucle for)
      $finish;
    end
endmodule


