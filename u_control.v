// Design: Multiplicador secuencial
// Description: Unidad de control del multiplicador
// Author: Paulino Ruiz de Clavijo V�zquez <paulino@dte.us.es>
// Modified by: Sergio Mart�n Guill�n
// Copyright Universidad de Sevilla, Spain
// Rev: 2, marzo 2013

// Usando `default_nettype none, el compilador no supone, por defecto, que las entradas
// y las salidas de los m�dulos son de tipo 'wire'. Obliga a declararlas 'wire' expresamente.
// Adem�s, gracias a esto, nos dar� un error siempre que estemos usando un
// cable no declarado previamente, en vez de suponer una declaraci�n impl�cita.
`default_nettype none


module u_control(
  input  wire xs, reset, SUML0, cycont, clk,
  output reg  clinicio, clc, wc, wa, wsumh, wsuml, shrsum, upcont, fin
  );

  // Declaraci�n de la lista de estados de la carta ASM.
  // Debe COMPLETARLA con los estados que faltan en la lista.
  parameter S0 = 3'b000,
            S1 = 3'b001;
            S2 = 3'b010;
            S3 = 3'b011;
            SF = 3'b100;

  // Declaraci�n de las variables estado_actual y siguiente_estado.
  // Debe COMPLETARLA para que tengan el TAMA�O CORRECTO.
  reg [2:0] estado_actual, siguiente_estado;


  // Proceso de cambio de estado. Utiliza las variables definidas previamente.
  always @(posedge clk,posedge reset)
      if(reset)
        estado_actual <= S0;
      else
        estado_actual <= siguiente_estado;


  // Proceso combinacional que calcula las salidas y el proximo estado.
  // Debe COMPLETARLO con la informaci�n obtenida a partir de la carta ASM.
  always @(*)
    begin
      // Ponemos a 0 todas las salidas, para que dentro del 'case' solo haya
      // que modificar el valor de las salidas que tengan que ponerse a 1.
      clinicio=0; clc=0; wc=0; wa=0; wsumh=0; wsuml=0; shrsum=0; upcont=0; fin=0;
      // Ponemos 'siguiente_estado' a S0 para que dentro del 'case' solo haya que
      // modificar 'siguiente_estado' cuando tenga que ponerse a un valor distinto de S0.
      siguiente_estado = S0;

      case (estado_actual)
        S0:
          if(xs)
            siguiente_estado = S1;
          else:
            siguiente_estado = S0;
        S1:
          begin
            clinicio = 1;
            wa = 1;
            wsuml = 1;
            siguiente_estado = S2;
          end
        
        S2:
          begin
            if(SUML0)
              wsumh = 1;
              wc = 1;
            else
              clc = 1;
            siguiente_estado = S3;
          end

          S3:
            begin
              shrsum = 1;
              upcont = 1;
              if(cycont)
                siguiente_estado = SF;
              else
                siguiente_estado = S2;
            end
          
          SF:
            siguiente_estado = S0;
       endcase
    end  // (del always)

endmodule


