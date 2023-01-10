
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
 
   DECLARE  @dtmStartDateDay DATETIME
   DECLARE  @dtmEndtDateDay DATETIME
   

    	IF (@intMode  =1)
	    BEGIN
	    
	          
	          SET @dtmStartDateDay =  CONVERT(DateTime, CONVERT(Char,   @dtmDate , 103) + '00:01'  , 103)
	          SET @dtmEndtDateDay =   CONVERT(DateTime, CONVERT(Char,   @dtmDate , 103) + '23:59'  , 103)
	          
	          --SET @dtmSingleDate = CONVERT(DateTime, CONVERT(Char, @dtmAppointDate , 103), 103)
	          
	          --SELECT tblclsVisit.intVisitId as 'intVisitId'
	          --FROM tblclsVisit
	          --WHERE tblclsVisit.dtmAppointmentDate BETWEEN @dtmStartDate AND @dtmEndtDate
	          
	          
	          SELECT TOP 10 tblclsVisit.intVisitId   
	          FROM tblclsVisit
	          WHERE ISNULL(tblclsVisit.dtmAppointmentDate,'19000101 00:00') > '19000101 00:00'
	          ORDER BY tblclsVisit.intVisitId  DESC 
	    
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
    DECLARE @lint_mincontfblock INT
    SET @lint_mincontfblock = 10
    
  -- marca de bloque reemplazado 
    DECLARE @lstr_blockMovMark VARCHAR(8)
    SET @lstr_blockMovMark ='TOMOV'
        
  -- inicio en numero
    DECLARE @lint_startHour int
    SET @lint_startHour= 7
    
    DECLARE @lint_startMinute int
    SET @lint_startMinute = 0
    
  -- inicio en texto
    DECLARE @lstr_startTime varchar(10)
    SET @lstr_startTime ='07:00'
    
  -- FIN en numero hora
    DECLARE @lint_endHour int 
    SET @lint_endHour = 15

  -- FIN en numero minuto
    DECLARE @lint_endMinute int 
    SET @lint_endMinute = 30
        
  -- fin en texto  
    DECLARE @lstr_endTime varchar(10)
    SET  @lstr_endTime = '15:30'

  -- fecha y hora inicio
    DECLARE @ldtm_StartTime datetime
  
  -- fecha y hora fin 
    DECLARE @ldtm_EndTime datetime 
    
   -- valore de incremento 
    DECLARE @lint_minute_increase INT
    SET  @lint_minute_increase = 30
  
  -- fecha, hora de inicio
    DECLARE @dtm_back_StartDateTime DATETIME
    SET @dtm_back_StartDateTime = CONVERT(DateTime, CONVERT(Char,   @dtmDate , 103) + @lstr_startTime  , 103)
    

  -- fecha , hora de fin 
    DECLARE @dtm_back_EndDateTime DATETIME
    SET @dtm_back_EndDateTime = CONVERT(DateTime, CONVERT(Char,   @dtmDate , 103) + @lstr_endTime  , 103)
    
   -- indice
   DECLARE @lint_idx_count
   SET @lint_idx_count =1
   
   -- limite contador
   DECLARE @lint_limit_Counter
   SET @lint_limit_Counter = 500
   
   
  -- estrucutras 
   -- tabla visita, cont, universal, posicion,bloque, bahia, fila , estiba, id grua
     CREATE TABLE  #ContainersTable
			   (               
			    intUniversalId numeric(16) NULL,
			    strContainer  varchar(20) NULL,
			    intVisitId numeric(16) NULL,
			    intItem  INT NULL,
			    strPosition varchar(20) NULL,
			    strBlock varchar(5) NULL,
			    strBay varchar(8) NULL,
			    strRow varchar(3) NULL,
			    strStow varchar(2) NULL, 			    
			    intMarkTime INT NULL, 
			    strTime  VARCHAR(15) NULL,
			    dateTimeMark  DATETIME NULL,
			    intCrane INT NULL,
			    strCraneval VARCHAR(10) NULL,
			    intOrderId INT NULL
			   )
	
    -- tabla de blqoues
     CREATE TABLE  #BlockTable
			  (               
			    strBlock     varchar(10) NULL,
			    intCountCont int NULL,
			    intCrane     int NULL,
			    strBlock     varchar(10) NULL
			  )	
    
    -- tabla de horas 
     CREATE TABLE  #TimeMarks
			  (                
			    intMarkTime          INT NULL,
			    strTime              VARCHAR(15) NULL,
			    dateTimeMark         DATETIME NULL,
			    intHour              INT NULL,
			    intMinute            INT NULL
			   )
		   
	 -->>generar horarios 
   

			   --- mientras el horario menor sea menor que el tope, y mientras no se alcance el tope del ciclo
			     WHILE ( @dtm_back_StartDateTime <=@dtm_back_EndDateTime  AND @lint_idx_count  < @lint_limit_Counter )
			                BEGIN
			                
			                	--INSERTAR 
				                -- obtener la hora en string de la fecha incrementada 
				                -- obtener la hora completa 
				                set @lstr_timeback = CONVERT(VARCHAR(3), DATEPART( HOUR, @dtm_back_StartDateTime)) + ':' + CONVERT(VARCHAR(3), DATEPART( MINUTE, @dtm_back_StartDateTime))
				                
				                -- obtener la hora en tiempo 
				                set @int_idxHour = CONVERT(INT,datepart(HOUR, @dtm_back_StartDateTime ) )
				                
				                -- obtener el minuto en tiempo
				                SET  @int_idxMinute= CONVERT(INT,datepart(MINUTE, @dtm_back_StartDateTime ) )
				
				                
				               -- insertar 
				                INSERT INTO #TimeMarks (intMarkTime , strTime, dateTimeMark , intHour , intMinute  )
						        VALUES ( @lint_idx_count , @lstr_timeback , @dtm_back_StartDateTime, @int_idxHour , @int_idxMinute )					                  
						        					        
						        SET  @lint_idx_count =    @lint_idx_count + 1
						        
						   		 -- INCREMENTO SIGUIENTE 					   		 
				                 -- en minutos agregar                   
				                  SET  @dtm_back_StartDateTime = DATEADD(MINUTE,@lint_minute_increase,@dtm_back_StartDateTime)			               
				                
			               END --  WHILE ( @dtm_back_StartDateTime <=@dtm_back_EndDateTime)                   
          -- <<generar horarios 

         -- >> obtener las visitas y contenedores agendadas por dia especifico
          
          INSERT INTO #ContainersTable
           (
            	intUniversalId , strContainer ,intVisitId ,intItem  ,
			    strPosition ,strBlock ,strBay ,strRow ,
			    strStow ,  intMarkTime , strTime  ,dateTimeMark  ,
			    intCrane ,strCraneval ,intOrderId 
           )
         SELECT
               --intUniversalId , strContainer ,intVisitId ,intItem  ,
               tblclsVisitContainer.intContainerUniversalId , tblclsVisitContainer.strContainerId , tblclsVisitContainer.intVisitId , tblclsVisitContainer.intVisitItemId
			   
			   -- strPosition ,strBlock ,strBay ,strRow ,
			   tblclsContainerInventory.strContainerInvYardPositionId , tblclsContainerInventory.strContainerInvBlockIdentifier , tblclsContainerInventory.strContainerInvPosBay, tblclsContainerInventory.strContainerInvPosRow
			   
			   -- strStow ,  intMarkTime , strTime  ,dateTimeMark  ,
			   tblclsContainerInventory.strContainerInvPosStow , 0 , '' , NULL 
			   
			   --  intCrane ,strCraneval ,intOrderId 
			   ,0 , '' , 0
			   
         FROM tblclsVisit
           INNER JOIN tblclsVisitContainer ON tblclsVisitContainer.intVisitId = tblclsVisit.intVisitId
           INNER JOIN tblclsService ON tblclsService.intServiceId = tblclsVisitContainer.intServiceId
           INNER JOIN tblclsContainerInventory ON tblclsContainerInventory.intContainerUniversalId = tblclsVisitContainer.intContainerUniversalId           
           
         WHERE tblclsVisit.dtmAppointmentDate BETWEEN  @dtmStartDateDay AND @dtmEndtDateDay
         --AND tblclsVisit.dtmVisitDatetimeIn = NULL
         --AND tblclsVisit.dtmVisitDatetimeOut = NULL
         AND  tblclsService.strServiceIdentifier = 'ENTLL'

         -- <<  fin obtener las visitas y contenedores agendadas por dia especifico


  -- si agrupar por bloques 
   INSERT INTO   #BlockTable
			  (               
			    strBlock    ,intCountCont ,intCrane  ,strBlock     
			  )	
     SELECT strBlock, COUNT(strContainer) , 0 , ''
     FROM #ContainersTable
     GROUP BY #ContainersTable.strBlock
     
     
   -- cursor por bloques 
   ---- un ciclo donde se este revisando el sieuinge contenedor 
    --- fin ciclo revisando
  --- fin cursor
  
        
	          
	    END -- IF (@intMode  =1)
    
 END  --END CREATE PROCEDURE spSetAppointOnTime

