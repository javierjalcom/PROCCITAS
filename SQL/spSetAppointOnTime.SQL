
/*
	DROP PROCEDURE spSetAppointOnTime
	--
	execute spSetAppointOnTime  @intMode=1, @dtmDate='20200101 00:00', @intQtyPerHour=15, @intQtyCrane=1		
	---------
*/

CREATE PROCEDURE spSetAppointOnTime   @intMode  int
                                      ,@dtmDate  datetime    
                                      ,@intQtyPerHour int
                                      ,@intQtyCrane int
                                        
AS 
 BEGIN 
 
   DECLARE  @dtmStartDate DATETIME
   DECLARE  @dtmEndtDate DATETIME
   

    	IF (@intMode  =1)
	    BEGIN
	    
	          
	          SET @dtmStartDate =  CONVERT(DateTime, CONVERT(Char,   @dtmDate , 103) + '00:01'  , 103)
	          SET @dtmEndtDate =   CONVERT(DateTime, CONVERT(Char,   @dtmDate , 103) + '23:59'  , 103)
	          
	          --SET @dtmSingleDate = CONVERT(DateTime, CONVERT(Char, @dtmAppointDate , 103), 103)
	          
	          --SELECT tblclsVisit.intVisitId as 'intVisitId'
	          --FROM tblclsVisit
	          --WHERE tblclsVisit.dtmAppointmentDate BETWEEN @dtmStartDate AND @dtmEndtDate
	          
	          
	          SELECT TOP 10 tblclsVisit.intVisitId   
	          FROM tblclsVisit
	          WHERE ISNULL(tblclsVisit.dtmAppointmentDate,'19000101 00:00') > '19000101 00:00'
	          ORDER BY tblclsVisit.intVisitId  DESC 
	          
	          
	    END -- IF (@intMode  =1)
    
 END  --END CREATE PROCEDURE spSetAppointOnTime

-----------
 --son varias gruas
  -- obtener el listdado de contenedores que son para ese dia , obtener la posicion, bloque , fila bahia estiba 
 -- ordenarlos por bloque , bahia ,
 -- obtener lista de bloques agrupados por cantidad de contenedores ,
 -- hacer un cursor por bloque

  -- inicio cursor
        -- ordernar por bahia
        -- -- obtener el listado de bahias , (numerica)
        -- obtener listado de bahias (numericas)
        -- agrupar habias numericas 
        -- cursor bahias numericas
          -- ordenar por letras
           -- cursor por letras 
                     -- order por numeros 
                     -- insertar primero los renglones 
                     
           -- fin cursor letras 
             

          
         -- ??? como hacer para insertar primero los niverles mas altos?
        --- fin cursor bahias numericas 
        
  -- fin cursor bloques 
  
  ------------
   -- variables 
  -- limite de minimo de contenedores  en bloque
  -- marca de bloque reemplazado 
  
  -- estrucutras 
   -- tabla visita, cont, universal, posicion,bloque, bahia, fila , estiba, id grua
   -- tabla de blqoues
   -- tabla de horas 
   
  -- si agrupar por bloques 
   -- cursor por bloques 
   ---- un ciclo donde se este revisando el sieuinge contenedor 
    --- fin ciclo revisando
  --- fin cursor
  
