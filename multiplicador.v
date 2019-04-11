// Design: Multiplicador secuencial
// Description: Interconexi�n de la unidad de datos y de control
// Author: Paulino Ruiz de Clavijo V�zquez <paulino@dte.us.es>
// Modified by: Sergio Mart�n Guill�n
// Copyright Universidad de Sevilla, Spain
// Rev: 2, marzo 2013

// Usando `default_nettype none, el compilador no supone, por defecto, que las entradas
// y las salidas de los m�dulos son de tipo 'wire'. Obliga a declararlas 'wire' expresamente.
// Adem�s, gracias a esto, nos dar� un error siempre que estemos usando un
// cable no declarado previamente, en vez de suponer una declaraci�n impl�cita.
`default_nettype none


module multiplicador(
  input  wire [3:0] a,      // Entrada del dato A
  input  wire [3:0] b,      // Entrada del dato B
  input  wire clk,          // Reloj del multiplicador
  input  wire xs,           // Se�al de comienzo (para la U. de Control)
  input  wire reset,        // Reset as�ncrono del sistema (para la U. de Control)
  output wire fin,          // Se�al de fin de operacion
  output wire [7:0] mult    // Resultado multiplicaci�n (solo es v�lido al activarse 'fin')
  );

  wire c_clinicio, c_clc, c_wc, c_wa, c_wsumh, c_wsuml, c_shrsum, c_upcont, c_cycont;

  // Aqu� debe definir 9 cables internos, cada uno de un solo bit,
  // para efectuar las conexiones entre la instancia del m�dulo
  // 'u_control' y la instancia del m�dulo 'u_datos'.
  // Puede darle los nombres que quiera siempre que no se est�n usando ya.

  
  // Aqu� debe crear una instancia del m�dulo 'u_datos'.
  // Use 'INST_u_datos' para el nombre de la instancia.
  // Al crear la instancia debe conectar sus entradas y salidas
  // a alguno de los cables internos que ha definido arriba y tambi�n
  // a alguno de los puertos de entrada y de salida del 'multiplicador'
  // Ay�dese de las figuras que aparecen en el manual de la pr�ctica.
  // Tambi�n puede abrir el archivo 'u_datos.v' para ver la
  // definici�n exacta de las entradas y salidas del m�dulo 'u_datos'.
  
  u_datos INST_u_datos( .datoA(a), .datoB(b), .clk(clk), .wa(c_wa), .upcont(c_upcont), 
                        .clinicio(c_clinicio), .wc(c_wc), .clc(c_clc), .wsumh(c_wsumh), .wsuml(c_wsuml), 
                        .shrsum(c_shrsum), .result(mult), .cycont(c_cycont));

  // Aqu� debe crear una instancia del m�dulo 'u_control'.
  // Use 'INST_u_control' (en may�scula) para el nombre de la instancia.
  // Al crear la instancia debe conectar sus entradas y salidas
  // a alguno de los cables internos que ha definido arriba y tambi�n
  // a alguno de los puertos de entrada y de salida del 'multiplicador'
  // Ay�dese de las figuras que aparecen en el manual de la pr�ctica.
  // Tambi�n puede abrir el archivo 'u_control.v' para ver la
  // definici�n exacta de las entradas y salidas del m�dulo 'u_control'.

  u_control INST_u_control(.xs(xs), .reset(reset), .SUML0(mult), .cycont(c_cycont), .clk(clk), 
                          .clinicio(c_clinicio), .clc(c_clc), .wc(c_wc), .wa(c_wa),
                          .wsumh(c_wsumh), .wsuml(c_wsuml), .shrsum(c_shrsum), .upcont(c_upcont), .fin(fin));


endmodule
