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
	    SET  @lstr_endTime = '15:00'
	
	  -- fecha y hora inicio
	    DECLARE @ldtm_StartTime datetime
	  
	  -- fecha y hora fin 
	    DECLARE @ldtm_EndTime datetime 
	    
	   -- valore de incremento 
	    DECLARE @lint_minute_increase INT
	    SET  @lint_minute_increase = 60
	    
	    DECLARE @lstr_timeback  VARCHAR(20)
	    SET @lstr_timeback=''
	  
	  -- fecha, hora de inicio
	    DECLARE @dtm_back_StartDateTime DATETIME
	    SET @dtm_back_StartDateTime = CONVERT(DateTime, CONVERT(Char,   @dtmDate , 103) + @lstr_startTime  , 103)
	    
	
	  -- fecha , hora de fin 
	    DECLARE @dtm_back_EndDateTime DATETIME
	    SET @dtm_back_EndDateTime = CONVERT(DateTime, CONVERT(Char,   @dtmDate , 103) + @lstr_endTime  , 103)
	    
	   -- indice
	   DECLARE @lint_idx_count INT
	   SET @lint_idx_count =1
	   
	   -- limite contador
	   DECLARE @lint_limit_Counter INT
	   SET @lint_limit_Counter = 500
	   
	   --indice de gruas 
	   DECLARE @lint_craneIdx INT
	   SET @lint_craneIdx=1
	   
	   -- valor de gruas 
	   DECLARE @lstr_craneid VARCHAR(10)
	   SET @lstr_craneid=''
	   
	   DECLARE @int_idxHour INT
	   DECLARE @int_idxMinute INT
	   
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
			    intOrderId INT NULL ,
			    intGenOrder INT NULL,
			    intGblok INT NULL
			   )
	
    -- tabla de blqoues
     CREATE TABLE  #BlockTable
			  (               
			    strBlock     varchar(10) NULL,
			    intCountCont int NULL,
			    intCrane     int NULL,
			    strBlockMark     varchar(10) NULL
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
			   
	-- tabla de gruas 
	 CREATE TABLE #CraneList
	           (
	             intCraneId  INT NULL,
	             strCraneLabel varchar (10) NULL
	           )
	           
	---- tabla de cantidad de gruas por tiempo 
	 CREATE TABLE #TimeMarkCraneG
	           (
	             intMarkTime INT NULL,
	             intCountCranes INT NULL,
	             intCrane INT NULL
	           )
	 
		-- marca tiempo, cantidad de gruas 
    -------------
	   
	 -->>generar horarios    
              SET @lint_idx_count = 1 
              
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

         -- >> llenar tabla de gruas 
	         WHILE (@lint_craneIdx<=@intQtyCrane)
	         BEGIN
	         
	               SET @lstr_craneid='00'+CONVERT(VARCHAR(3),@lint_craneIdx)
	               
	        		-- insertar grua 
			        INSERT INTO #CraneList
			           (
			            	intCraneId ,
			            	strCraneLabel 
			           )
			        VALUES (@lint_craneIdx,@lstr_craneid)
			           
			       	SET @lint_craneIdx = @lint_craneIdx +1    
	             --- 
	         END  --  WHILE (@lint_craneIdx<=@intQtyCrane)         
        -- << llenar tabla de gruas 
        

   SET @lint_craneIdx=1
   
   -- valor de gruas   
   SET @lstr_craneid=''
         --<< fin  llenar tabla de gruas 

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
			   ,tblclsContainerInventory.strContainerInvYardPositionId , tblclsContainerInventory.strContainerInvBlockIdentifier , tblclsContainerInventory.strContainerInvPosBay, tblclsContainerInventory.strContainerInvPosRow
			   
			   -- strStow ,  intMarkTime , strTime  ,dateTimeMark  ,
			  , tblclsContainerInventory.strContainerInvPosStow , 0 , '' , NULL 
			   
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
         
         --  actualizar los bloques en mayusculas          
          UPDATE #ContainersTable
          SET #ContainersTable.strBlock = UPPER(#ContainersTable.strBlock)
         
         -- 
          -- si hay contenedores con posicion de 2 letras , y no tienen bloque , ponerle la posicion como bloque 
           UPDATE #ContainersTable
           SET #ContainersTable..strBlock = SUBSTRING(#ContainersTable.strPosition,1,2)
           WHERE
                     ( ISNULL(#ContainersTable.strBlock,'X') ='X'
                      and ISNULL(#ContainersTable.strPosition,'X') <>'X'
                      AND LEN(#ContainersTable.strPosition)>1

                     ) 
           
          ---
  		-- si agrupar por bloques 
		     INSERT INTO   #BlockTable
					  (               
					    strBlock ,intCountCont ,intCrane  ,strBlockMark
					  )	
			  
     SELECT strBlock, COUNT(strContainer) , 0 , ''
     FROM #ContainersTable
     GROUP BY #ContainersTable.strBlock
     
     DECLARE @lstr_blockId varchar(10)
     DECLARE @lint_CountContIdx int
     
     -- contador de iteracion 
     DECLARE @lint_whileidx int
      SET @lint_whileidx = 0 
     
     -- limite de itecion
     DECLARE @lint_whiletop INT
      SET @lint_whiletop= 800
     
     SET @lstr_blockId =''
     SET @lint_CountContIdx =0
     ----
          --- cantidad contenedores pendientes por marcar
     DECLARE @lint_pendingconts INT
     SET @lint_pendingconts =0

     -- menor renglon
     DECLARE @lstr_rowMIN varchar(7)
     SET @lstr_rowMIN=''
     
     --mayor renglon 
     DECLARE @lstr_rowMAX varchar(7)
     SET @lstr_rowMAX=''
    
         --mayor nivel
     DECLARE @lstr_stowMAX varchar(7)
     SET @lstr_stowMAX=''

     -- contenedor encontrado
     DECLARE @lstr_containerFound varchar(20)
     SET @lstr_containerFound = ''
     
      -- grua actual
      DECLARE @lint_CurrentCraneIdx INT
      set @lint_CurrentCraneIdx =0

      -- bahia actual
      DECLARE @lstr_CurrentBay varchar(5)
      SET @lstr_CurrentBay =''

      -- row actual
      DECLARE @lstr_CurrentRow varchar(5)
      SET @lstr_CurrentRow =''


      -- nivel actual
      DECLARE @lstr_CurrentStow varchar(3)
      SET @lstr_CurrentStow  =''

      -- marca de tiempo encontrada
      DECLARE @lint_FoundMarkTime int
      SET @lint_FoundMarkTime =0
  
      --tiempo encontrado
      DECLARE @ldtm_foundDate datetime
      SET @ldtm_foundDate = NULL
      
      -- fecha nula 
      DECLARE @ldtmNULDATE datetime
      SET @ldtmNULDATE  ='19000101 00:00'

      -- cantidad de gruas encontrada
      DECLARE @lint_cranecountfound INT
      SET @lint_cranecountfound =0
       
     -- variable secundaria de grua encontrada
      DECLARE @lint_craneotherfound INT 
      SET @lint_craneotherfound  =0
 
      -- orden en bloque 
      DECLARE @lint_orderinblock INT
      SET @lint_orderinblock =0


     -- menor BAY
     DECLARE @lstr_BAYMIN varchar(7)
     SET @lstr_BAYMIN=''
     
     --mayor BAY
     DECLARE @lstr_BAYMAX varchar(7)
     SET @lstr_BAYMAX=''
          
     -- actual BAY
     DECLARE @lstr_CurrentBAY varchar(7)
     SET @lstr_CurrentBAY=''
     
      -- contador de contenedores
      DECLARE @lint_countcont INT
      SET @lint_countcont = 0
     --------
     
      -- entero temporal
      DECLARE @lint_tempint INT
      SET @lint_tempint = 0

      -- temporal string 
      DECLARE @lstr_tempstring varchar(20)
      SET @lstr_tempstring = ''
     --------
     -- secuendia general
     DECLARE @lint_GeneralOrder INT
     SET @lint_GeneralOrder = 0
     
     -- contador de bloques
     DECLARE @lint_GBlockC INT
     SET @lint_GBlockC = 0
     
      -- temporal fecha
      DECLARE @ldtm_tempdate datetime
      set @ldtm_tempdate = NULL
      ------------
      DECLARE @lstr_message VARCHAR(100)
      
      --SELECT  * FROM #BlockTable
      --SELECT * FROM  #TimeMarks
       --     SELECT * FROM  #CraneList
        --          SELECT * FROM #TimeMarkCraneG
    -- select * from #ContainersTable return 0 
            SET @lint_cranecountfound = 0
      
 	  -- cursor por bloques 
	       DECLARE blockcur  CURSOR FOR  
                  SELECT strBlock , intCountCont
                  FROM #BlockTable
                  ORDER BY intCountCont DESC
                  
                  --FOR READ ONLY 
                  -- abrir el cursor
                   OPEN blockcur
                   
                   -- leer el cursor 
                   FETCH  blockcur INTO @lstr_blockId ,  @lint_CountContIdx
                   --
                   SET @lint_GBlockC  = @lint_GBlockC  +1 
                   
                   -- PRINT 'inicio cursor'
                   --
                   -- ciclo del cursor 
                   WHILE ( @@sqlstatus = 0 )
                          begin
                          SET @lstr_message = '406- INCIA CURSOR BK='+ @lstr_blockId+ CONVERT(VARCHAR(5),@lint_CountContIdx)
                          --PRINT @lstr_message
		  					    -- si el bloque contiene cantidad mayor
		  					   -- IF (@lint_CountContIdx >=  @lint_mincontfblock )		  					    
		  					    IF (@lint_CountContIdx >=  1 )		  					    
		  					    -- poner el id de orden en el bloque en 0
			  					    BEGIN
			  					        -- obtener la cantidad de contenedores pendientes por macar 
				  					        SELECT @lint_pendingconts  = COUNT(strContainer  )
				  					        FROM #ContainersTable
				  					        WHERE strBlock =  @lstr_blockId
				  					        AND ISNULL(intOrderId ,0) =0
				  					        
			  					        -- incializa indice de contandor
			  					             SET @lint_whileidx = 0 
			  					           
							         	-- obtener el menor  renglon BAY, ,sin marcar
							              	SELECT @lstr_BAYMIN= MIN(strBay )
							         	    FROM #ContainersTable
							         	    WHERE strBlock =  @lstr_blockId
							         	    AND ISNULL(intOrderId ,0) =0
							         	    
							         	    SET @lstr_BAYMIN= ISNULL(@lstr_BAYMIN,'')
							         	    SET @lstr_CurrentBAY=@lstr_BAYMIN
							         	    
							         	    
							         	-- obtener el menor row,y el renglon-bay escogido sin marcar 

							         	     SELECT  @lstr_rowMIN   =MIN(strRow )
							         	     FROM #ContainersTable
							         	    WHERE strBlock =  @lstr_blockId
							         	    AND ISNULL(intOrderId ,0) =0
							         	    AND strBay = @lstr_CurrentBAY
							         	    --AND @lstr_stowMAX = strStow 
							         	    
							         	    SET @lstr_CurrentRow  = @lstr_rowMIN

	
							         	-- obtener el nivel maximo, , del menor row,  sin marcar
							         	    SELECT  @lstr_stowMAX  =  MAX(strStow  )
							         	     FROM #ContainersTable
							         	    WHERE strBlock =  @lstr_blockId
							         	    AND ISNULL(intOrderId ,0) =0
							         	    AND strBay = @lstr_CurrentBAY
							         	    and strRow = @lstr_rowMIN
							         	    
							         	    SET  @lstr_CurrentStow = @lstr_stowMAX
							         	    
							         	-- obtener los contenedores del bloque sin marcar 
							         	SELECT  @lstr_containerFound = MIN (strContainer )
							         	FROM #ContainersTable
							         	WHERE strBlock =  @lstr_blockId
							         	    AND ISNULL(intOrderId ,0) =0
							         	    AND @lstr_CurrentBAY = strBay 
							         	    AND @lstr_stowMAX = strStow 
							         	    AND @lstr_rowMIN  = strRow

							         	-- inicializar el contador de iteciones 
							         	  SET @lint_whileidx = 0 
							         	  
				         				-- incializa indice de contandor
				         				  SET @lint_orderinblock =0
				         				  SET @lint_whileidx = 1
				         				  
				         				-- generar contador disponible conteneodes sin marcar
				         				    SELECT @lint_pendingconts  = COUNT(strContainer  )
				  					        FROM #ContainersTable
				  					        WHERE strBlock =  @lstr_blockId
				  					        AND ISNULL(intOrderId ,0) =0

							         					---- un ciclo donde se este revisando el sieuinge contenedor , mientras contador de  disponible sea mayor a 0 y contador de iteracion menor que elilimte 
							         					WHILE ( ( @lint_pendingconts>0 ) AND ( @lint_whileidx < @lint_whiletop )  )
							         					BEGIN
							         					 --SET @lstr_message = '476- INCIA CICLO PCONT=' + CONVERT(VARCHAR(5),@lint_pendingconts) +'WHILEID='+CONVERT(VARCHAR(5),@lint_whileidx)+'TOP'+CONVERT(VARCHAR(5),@lint_whiletop)
							         					-- PRINT @lstr_message
								         					 -- obtener el contenedor con bloque, renglon, bahia 
								         					 	SELECT  @lstr_containerFound = MIN (strContainer )
								         					 	FROM #ContainersTable
								         					 	 WHERE strBlock =  @lstr_blockId
								         					 	 AND ISNULL(intOrderId ,0) =0
								         					 	 AND @lstr_CurrentBAY = strBay 
								         					 	 AND @lstr_stowMAX = strStow 
								         					 	 AND @lstr_rowMIN  = strRow
								         					 	 
								         					SET @lstr_message = '498-BLOCK=' + @lstr_blockId +'BAY='+@lstr_CurrentBAY+'ROW='+@lstr_rowMIN + 'STOW='+@lstr_stowMAX + '-CONT='+@lstr_containerFound
							         					   --  PRINT @lstr_message

								         					 
								         					 -- obtener la ultima marca de tiempo ,para el bloque y la grua , 
								         					     SELECT @lint_FoundMarkTime = MAX( intMarkTime )
								         					     FROM  #ContainersTable
								         					     WHERE  strBlock =  @lstr_blockId
								         					     
								         					 --  @lint_FoundMarkTime
								         					    SET @lint_FoundMarkTime = ISNULL(@lint_FoundMarkTime,0)
								         					 	 

								         					  --si no lo enocontro , 
								         					  IF (@lint_FoundMarkTime=0)
								         					  BEGIN
								         					       -- buscar la hora menor. que no tenga el limite de gruas 
								         					        	---- tabla de cantidad de gruas por tiempo 
								         					        	DELETE #TimeMarkCraneG
								         					        	
								         					        	INSERT INTO #TimeMarkCraneG(intMarkTime ,intCountCranes, intCrane  )
								         					        	SELECT intMarkTime,0 ,intCrane
								         					        	FROM  #ContainersTable
								         					        	where intMarkTime >0
								         					        	and intCrane > 0 
								         					        	GROUP BY intMarkTime,intCrane
								         					        	
								         					        	UPDATE #TimeMarkCraneG
								         					        	SET #TimeMarkCraneG.intCountCranes= (SELECT COUNT(SCRANE.intCrane)
								         					        	                                     FROM #TimeMarkCraneG SCRANE
								         					        	                                     WHERE SCRANE.intMarkTime = #TimeMarkCraneG.intMarkTime
								         					        	                                     --GROUP BY SCRANE.intMarkTime

								         					        	                                    )
								         					        	
								         					        	/*if exists ( select intCountCranes
								         					        	            from #TimeMarkCraneG
								         					        	            where #TimeMarkCraneG.intCountCranes > 1
								         					        	            )
								         					        	            begin
								         					        	             select  *
								         					        	             from #TimeMarkCraneG
								         					        	             
								         					        	             return 0 
								         					        	            end 
								         					        	*/
								         					        	
								         					        	SELECT  @lint_FoundMarkTime =  MIN(intMarkTime)
								         					        	FROM #TimeMarkCraneG
								         					        	WHERE intCountCranes < @intQtyCrane
								         					        	
								         					        	SET @lint_FoundMarkTime = ISNULL(@lint_FoundMarkTime,0)
								         					        	
								         					        	SET @lstr_message = '537-BK='+@lstr_blockId +'- T='+convert(varchar(5),@lint_FoundMarkTime)
								         					        	--PRINT @lstr_message
								         					       -- si no hay hora
								         					        IF (@lint_FoundMarkTime =0)
								         					        BEGIN
								         					            set @lint_tempint = 0
								         					           -- obtener la maxima cantidad de tiempo , si no hay ,ponerla en 1
								         					            SELECT @lint_tempint = MAX( #ContainersTable.intMarkTime  ) 
								         					            FROM #ContainersTable
								         					            
								         					           -- si hay maxima cAntIdad, sumarle 1
								         					           IF ( @lint_tempint > 0)
								         					             BEGIN
								         					               SET @lint_cranecountfound=1								         					                     
								         					             END
								         					           ELSE
								         					            BEGIN -- sino								         					            	  								         					             
									         					           --empezar desde el indice de tiempo 0 
									         					            SET @lint_FoundMarkTime = 1
								         					            END 
								         					          -- fin si no lo encontro		
									         					      
								         					        END -- IF (@lint_FoundMarkTime =0)   
								         					        
								         					              SET @lstr_message = '576-BK='+@lstr_blockId +'- T='+convert(varchar(5),@lint_FoundMarkTime)
								         					        	--PRINT @lstr_message
								         					        	
								         					        	SET  @lint_tempint =0
									         					       -- ver si existen gruas en ese tiempo
									         					        SELECT  @lint_tempint = COUNT(intCountCranes )
									         					        FROM  #TimeMarkCraneG
									         					        WHERE #TimeMarkCraneG.intMarkTime =@lint_FoundMarkTime
									         					        
									         					        SET  @lint_tempint =ISNULL( @lint_tempint,0)
									         					        
									         					        -- si la cantidad de gruas es menor que las disponibles 
									         					         IF ( @lint_tempint < @intQtyCrane )
									         					         BEGIN
									         					            -- obtner la ultima grua y sumarle 1
									         					            SELECT @lint_tempint = MAX(intCrane  )
									         					            FROM #ContainersTable
									         					            WHERE #ContainersTable.intMarkTime =@lint_FoundMarkTime
									         					            									         					            
									         					            -- si la grua es mayor a limite, empezar en 1
									         					            SET @lint_tempint = @lint_tempint +1
									         					            
									         					            IF ( @lint_tempint > @intQtyCrane)
									         					         	   BEGIN
									         					         	     --
									         					         	     --   SET  @lint_FoundMarkTime  = @lint_tempint  +1
										         					             -- es nuevo tiempo 
										         					                 -- obtener la ultima grua usada en el anterior tiempo
										         					                 --SET @lint_tempint =0 
										         					                --  SELECT @lint_tempint= MAX(intCrane )
										         					                --  FROM #ContainersTable
										         					                --  WHERE  #ContainersTable.intMarkTime  =  @lint_tempint
										         					                  
										         					                   -- la nueva grua sera la ulitama usada +1
										         					                 --  SET @lint_cranecountfound = @lint_tempint +1
										         					                    -- si la nueva grua es mayor que la cantidad, empezar en 1
										         					                   -- IF ( @lint_cranecountfound > @intQtyCrane)
										         					                    -- BEGIN 
										         					                      -- incializar busqueda  
										         					                       SET @lint_cranecountfound=0
										         					                        --
										         					                        SELECT @lint_cranecountfound = MIN(intCraneId )
										         					                        FROM  #CraneList
										         					                        WHERE  #CraneList.intCraneId  NOT IN (SELECT #TimeMarkCraneG.intCrane 
										         					                                                              FROM  #TimeMarkCraneG
										         					                                                              WHERE #TimeMarkCraneG.intMarkTime =  @lint_FoundMarkTime
										         					                                                             )
									         					         	     ---
										         					            -- - SET @lint_cranecountfound =1
										         					            END --   IF ( @lint_tempint > @intQtyCrane)
									         					            ELSE
									         					             BEGIN
									         					               SET @lint_cranecountfound= @lint_tempint
									         					             END -- ELSE --   IF ( @lint_tempint > @intQtyCrane)									         					            

									         					         END -- si la cantidad de gruas es menor que las disponibles 
									         					         -- IF ( @lint_tempint < @intQtyCrane )									         					       
									         					            
									         					        --??? si no hay gruas en esa hora, empezar en 1 
									         					        
									         					        SET @lstr_message = '611-BK='+@lstr_blockId +'- concrane='+convert(varchar(5),@lint_cranecountfound)
								         					        	--PRINT @lstr_message
								         					              
								         					  --
								         					  END --  IF (@lint_FoundMarkTime=0)
								         					 ELSE --	si encontro la marca de tiempo
								         					  BEGIN 
								         					       -- contar cuantos contenedores se han cargado en esa marca de tiempo, si ya esta en el limite , avanzar a la siguiente marca de tiempo
								         					        SELECT @lint_countcont =  COUNT( strContainer  )
								         					        FROM #ContainersTable
								         					        WHERE  #ContainersTable.intMarkTime   = @lint_FoundMarkTime 
								         					        AND  strBlock =  @lstr_blockId
								         					        
								         					        IF ( @lint_countcont >=@intQtyPerHour)
								         					        BEGIN 
								         					          SET  @lint_FoundMarkTime = @lint_FoundMarkTime +1 
								         					          
								         					          SET @lstr_message = '629- NUEVA MARKA TIEMPO Mk='+ CONVERT(VARCHAR(3),@lint_FoundMarkTime )  +'BLK='+@lstr_blockId+'CRAN='+ CONVERT(VARCHAR(3),@lint_cranecountfound )  
								         					         -- PRINT @lstr_message
								         					          
								         					        END  --IF ( @lint_countcont >@intQtyPerHour)

								         					        
								         					  END  -- ELSE IF (@lint_FoundMarkTime=0)
								         					  
								         					  
								         					  -- fin si encontro la marca de tiempo									         					  
								         					  							         					 
                                                                SET @lint_cranecountfound = ISNULL(@lint_cranecountfound,0)
								         					    -- si no hay  grua 
								         					    IF ( @lint_cranecountfound =0)
								         					    BEGIN
								         					      -- obtener la grua 1
								         					      SET  @lint_cranecountfound =1 								         					      
								         					    END 

								         					 
								         					 -- si la marca de tiempo es 0, ponerla en 1 
								         					 IF (@lint_FoundMarkTime =0)
								         					 BEGIN
								         					  --SET @lint_FoundMarkTime =1 
								         					   -- buscar la hora menor que no este ocuapda 
								         					   SELECT @lint_FoundMarkTime= MIN(intMarkTime) 
								         					   FROM #TimeMarks
								         					   WHERE #TimeMarks.intMarkTime NOT IN (
								         					                                           SELECT #ContainersTable.intMarkTime
								         					                                           FROM #ContainersTable
								         					                                           GROUP BY #ContainersTable.intMarkTime 
								         					                                       ) 
								         					   -- sino encontro buscar ultima hora de la tabla 
								         					   SET @lint_FoundMarkTime =ISNULL( @lint_FoundMarkTime,0)
								         					   
								         					     IF ( @lint_FoundMarkTime=0)
								         					     BEGIN
								         					             SELECT @lint_FoundMarkTime= MAX(intMarkTime) 
								         					             FROM #TimeMarks
								         					     END -- @lint_FoundMarkTime=0
								         					 END  --	IF (@lint_FoundMarkTime =0)
								         					 
								         					 -- definirle el id de orden en el bloque 
								         					 -- obtener el ulitmo id de orden en el bloque , 
								         					 SELECT  @lint_tempint = MAX(intOrderId )
								         					 FROM #ContainersTable
								         					 WHERE strBlock =  @lstr_blockId
								         					 
								         					 --- validar
								         					 SET  @lint_tempint = ISNULL( @lint_tempint,0)
								         					 SET @lint_orderinblock = @lint_tempint
								         					 
								         					 -- si no existe ponerle el id 1
								         					 IF( @lint_orderinblock =0)
									         					 BEGIN
									         					  SET @lint_orderinblock = 1
									         					 END 
								         					 ELSE 
									         					 BEGIN
									         					    SET @lint_orderinblock = @lint_orderinblock +1 
									         					 END 	
									         					 							         		

								         					 -- si el id de orden no esta, ponerle 0								         					  
								         					 -- obtener los valores de  fecha del catalogo
								         					   SELECT @lstr_tempstring = strTime  
								         					         ,@ldtm_tempdate =dateTimeMark         
								         					   FROM #TimeMarks
								         					   WHERE intMarkTime=@lint_FoundMarkTime 
								         					 
								         					 ---- obtener el orden general	         	
								         					 		SELECT  @lint_GeneralOrder = MAX(intGenOrder)
								         					 		FROM #ContainersTable
								         					 		SET  @lint_GeneralOrder =  ISNULL(@lint_GeneralOrder,0)
								         					 		SET  @lint_GeneralOrder =  @lint_GeneralOrder +1 	
								         					 								         					 			 
								         					 -- marcar la tabla con el contenedor , en la marca de tiempo y grua ,
								         					 UPDATE #ContainersTable
								         					 SET #ContainersTable.intOrderId =@lint_orderinblock
								         					    ,#ContainersTable.intMarkTime = @lint_FoundMarkTime 
								         					    ,strTime  = strTime 
								         					    ,dateTimeMark=@ldtm_tempdate
								         					    ,intCrane = @lint_cranecountfound
								         					    ,intGblok   = @lint_GBlockC
								         					    ,intGenOrder  = @lint_GeneralOrder
								         					 WHERE @lstr_containerFound = strContainer
								         					 AND ISNULL( #ContainersTable.intOrderId,0) =0
								         					 
								         					 -- si el contenedor no tiene marca de grua de nobmre ponerselo el nombre de grua strCraneval 
								         					   -- obtener la marca de la grua en listado de contenedores
								         					    SET @lstr_tempstring=''
								         					    --
								         					    SELECT @lstr_tempstring =  strCraneval 
								         					    FROM   #ContainersTable
								         					    WHERE @lstr_containerFound = strContainer
								         					   SET  @lstr_tempstring = ISNULL( @lstr_tempstring ,'')
								         					   
								         					    IF ( LEN(@lstr_tempstring) <=2) -- SI NO HAY MARCA
								         					    BEGIN
								         					      
								         					      -- OBTENER NOMBRE DE GRUA 
								         					      SELECT @lstr_tempstring =strCraneLabel 
								         					      FROM  #CraneList
								         					      WHERE intCraneId   =  @lint_cranecountfound
								         					      -- PONER EL ID DE GRUA STRING  
								         					       UPDATE #ContainersTable
								         					       SET strCraneval =  @lstr_tempstring
								         					       WHERE @lstr_containerFound = strContainer
								         					       
								         					    END -- SI NO HAY MARCA strCraneval
								         					    
								         					 
								         					 -- bucar la siguiente posicion		
								         					  
								         					  
								         					    -- ver si el contendor actual hay otros contenedores de visita 								         					    
								         					     -- obtener la visita 
								         					     SET @lint_tempint =0
								         					     SELECT @lint_tempint = #ContainersTable.intVisitId 
								         					     FROM #ContainersTable
								         					     WHERE #ContainersTable.strContainer = @lstr_containerFound								         					  
								         					     
								         					    -- si hay contenedores en la visita de otros bloques, ponerles una marca en comentario, en strCraneval 
								         					     UPDATE #ContainersTable
								         					     SET strCraneval  = 'B='+ @lstr_blockId
								         					     WHERE #ContainersTable.intVisitId =  @lint_tempint
								         					     AND  #ContainersTable.strContainer <> @lstr_containerFound
								         					     AND   strBlock <>  @lstr_blockId
								         					     AND  ISNULL(strCraneval,'')=''
								         					  
								         					  SET @lstr_tempstring =''
								         					  SET @lint_tempint =ISNULL( @lint_tempint,0)
								         					     
								         					    -- ver si hay contenedores en la visita, pero con el mismo bloque							         					     
								         					    IF EXISTS ( SELECT strContainer  FROM #ContainersTable
								         					                                    WHERE #ContainersTable.intVisitId =  @lint_tempint
								         					                                    AND  #ContainersTable.strContainer <> @lstr_containerFound
								         					                                    AND   strBlock =  @lstr_blockId
								         					                                    AND  ISNULL(intOrderId ,0)=0
								         					      )
									         					    BEGIN
									         					    --  -- si hay contenedores  con visita del mismo bloque
									         					            -- obtener el menor contenedor si marcar
									         					            SELECT @lstr_tempstring = MIN(#ContainersTable.strContainer)
									         					            FROM #ContainersTable
									         					            WHERE #ContainersTable.intVisitId =  @lint_tempint
									         					            AND  #ContainersTable.strContainer <> @lstr_containerFound
									         					            AND   strBlock =  @lstr_blockId
									         					            AND  ISNULL(intOrderId ,0)=0
									         					            
									         					            -- obtener su bloque , fila, bahia, estiba 
									         					            SELECT @lstr_BAYMIN = strBay 
									         					                  ,@lstr_rowMIN= strRow 
									         					                  , @lstr_stowMAX  = strStow 
									         					            FROM #ContainersTable
									         					            WHERE  #ContainersTable.strContainer =@lstr_tempstring 
									         					            
									         					            SET @lstr_CurrentBAY =  @lstr_BAYMIN
									         					            
									         					              SET @lstr_message = '783-VISITA--BLOCK=' + @lstr_blockId +'_BAY='+@lstr_CurrentBAY+'_ROW='+@lstr_rowMIN + 'STOW='+@lstr_stowMAX --+ '-CONT='+@lstr_containerFound
												         					  --PRINT @lstr_message
									         					            
									         					    END -- IF EXISTS ( SELECT strContainer  FROM #ContainersTable WHERE #ContainersTable.intVisitId =  @lint_tempint									         					    
								         					    ELSE  -- si no hay contenedores en la misma visita 
								         					    BEGIN
								         					      -- ver si en la bahia actual ahi contenedores sin marcar 
								         					     
								         					      -- si hay contenedores en la bahia actual
								         					      IF EXISTS (  SELECT strContainer  FROM #ContainersTable 
								         					                   WHERE #ContainersTable.strBay  =   @lstr_CurrentBAY
								         					                   AND   strBlock =  @lstr_blockId
								         					                   AND  ISNULL(intOrderId ,0)=0
								         					                 )
								         					             BEGIN			
								         					             
								         					                 -- obtener el row menor  sin marcar 
										         					         SELECT @lstr_rowMIN=MIN(strRow  )
										         					         FROM #ContainersTable
										         					           WHERE #ContainersTable.strBay  = @lstr_CurrentBAY
								         					                   AND   strBlock =  @lstr_blockId
								         					                   AND  ISNULL(intOrderId ,0)=0
								         					                   --AND  @lstr_stowMAX =strStow 
								         					             					         					      		
										         					         -- obtener  el nivel mas alto sin marcar, con el row menor
										         					         SELECT  @lstr_stowMAX =MAX(strStow )
										         					         FROM #ContainersTable
										         					           WHERE #ContainersTable.strBay  =   @lstr_CurrentBAY
								         					                   AND   strBlock =  @lstr_blockId
								         					                   AND  ISNULL(intOrderId ,0)=0
										         					           AND  strRow = @lstr_rowMIN
										         					       

										         					         	SET @lstr_message = '809-MISMABAY--BLOCK=' + @lstr_blockId +'_BAY='+@lstr_CurrentBAY+'_ROW='+@lstr_rowMIN + 'STOW='+@lstr_stowMAX + '-CONT='+@lstr_containerFound
										         					         --	PRINT @lstr_message
										         					         	
									         					        END --IF EXISTS (  SELECT strContainer  FROM #ContainersTable WHERE #ContainersTable.strBay  =   @lstr_CurrentBAY
									         					   ELSE
									         					    BEGIN ----IF EXISTS (  SELECT strContainer  FROM #ContainersTable WHERE #ContainersTable.strBay  =   @lstr_CurrentBAY
 
										         					      --- si no hay contenedores en la bahia actual 
										         					              SET @lstr_BAYMAX =''
												         					      --- obtener la maxima habia menor que la actual con contenedores sin marcar
												         					      SELECT @lstr_BAYMAX = MAX(strBay )
												         					      FROM  #ContainersTable 
												         					      WHERE strBay < @lstr_CurrentBAY
												         					      AND ISNULL(intOrderId ,0)=0
												         					      AND strBlock =  @lstr_blockId
												         					      --
												         					      SET @lstr_BAYMAX =ISNULL( @lstr_BAYMAX,'X')
												         					      
												         					      --- obtener la minima bahia mayor que la actual con contendores sin marcar								         					      
												         					      SET @lstr_BAYMIN  =''
												         					      
												         					      SELECT @lstr_BAYMIN = MIN(strBay )
												         					      FROM  #ContainersTable 
												         					      WHERE strBay > @lstr_CurrentBAY
												         					      AND ISNULL(intOrderId ,0)=0
												         					      AND strBlock =  @lstr_blockId
												         					      --
												         					      SET @lstr_BAYMIN =ISNULL( @lstr_BAYMIN,'X')
												         					      
												         					      -- si existe ya sea la bahia menor o mayor evaluar 
												         					      IF( ( @lstr_BAYMIN <>'' AND @lstr_BAYMIN<>'X') OR (@lstr_BAYMAX<>'' AND @lstr_BAYMAX<>'X') )
												         					      BEGIN
												         					             SET @lint_countcont =0
														         					      -- obtener la cantidad de contenedores la bahia menor
														         					      SELECT @lint_countcont = COUNT(strContainer   )
														         					      FROM #ContainersTable
														         					      WHERE #ContainersTable.strBay = @lstr_BAYMIN 
														         					      AND ISNULL(intOrderId ,0)=0
														         					      AND strBlock =  @lstr_blockId
														         					     
														         					      SET @lint_countcont = ISNULL( @lint_countcont,0)
														         					      
														         					      -- obtener la cantidad de contenedores la bahia mayor
														         					      SET @lint_tempint  =0 
														         					        SELECT @lint_tempint  = COUNT(strContainer   )
														         					      FROM #ContainersTable
														         					      WHERE #ContainersTable.strBay = @lstr_BAYMAX 
														         					      AND ISNULL(intOrderId ,0)=0
														         					      AND strBlock =  @lstr_blockId
														         					      
														         					      SET @lint_tempint  = ISNULL(@lint_tempint ,0)
														         					      
														         					      -- si la cantidad de la bahia menor es mayor o igual que el de la mayor
														         					      IF ( @lint_countcont >=@lint_tempint)
															         					      BEGIN
															         					        -- indicar que la proxima bahia sera la menor 
															         					        SET   @lstr_CurrentBAY  =  @lstr_BAYMIN
															         					      END 											
														         					     -- si no
														         					     ELSE														         					      	
															         					     BEGIN
															         					          -- indicar que la proxima bahia sera la mayor	
															         					         SET @lstr_CurrentBAY  = @lstr_BAYMAX 
															         					      
															         					      END  --ELSE--IF ( @lint_countcont >=@lint_tempint)  -- si la cantidad de la bahia menor es mayor o igual que el de la mayor
															         					     	
															         				
															         				      -- obtener el row menor  sin marcar 
															         				      SELECT @lstr_rowMIN=MIN(strRow  )
															         				      FROM #ContainersTable
															         				      WHERE #ContainersTable.strBay  = @lstr_CurrentBAY
															         				      AND   strBlock =  @lstr_blockId
															         				      AND  ISNULL(intOrderId ,0)=0
															         				      --AND  @lstr_stowMAX =strStow 	
										         					                   
															         				     -- obtener  el nivel mas alto para el row sin marcar
												         					        	 SELECT  @lstr_stowMAX =MAX(strStow )
													         					         FROM #ContainersTable
													         					           WHERE #ContainersTable.strBay  =   @lstr_CurrentBAY
											         					                   AND   strBlock =  @lstr_blockId
											         					                   AND  ISNULL(intOrderId ,0)=0
										         					                       AND  strRow = @lstr_rowMIN
										         					         
												         					              --
												         					              SET @lstr_message = '895-DIFMABAY--BLOCK=' + @lstr_blockId +'_BAY='+@lstr_CurrentBAY+'_ROW='+@lstr_rowMIN + 'STOW='+@lstr_stowMAX --+ '-CONT='+@lstr_containerFound
												         					             -- PRINT @lstr_message
								         					                   
												         					     	
												         					 	   END -- IF ( @lstr_BAYMIN <>'' AND @lstr_BAYMIN<>'X') OR (@lstr_BAYMAX<>'' AND @lstr_BAYMAX<>'X') )
												         					 	   
														         			    --- fin si existe  alguna bahia con contenedores con marcar  					      													         			    
														         			      
												         			 END-- ELSE --IF EXISTS (  SELECT strContainer  FROM #ContainersTable WHERE #ContainersTable.strBay  =   @lstr_CurrentBAY
												         		 -- fin si no hay contenedores en la misma bahia actual 
												         		 
												         		 
												         	 END --ELSE IF EXISTS ( SELECT strContainer  FROM #ContainersTable WHERE #ContainersTable.intVisitId =  @lint_tempint
								         					  -- fin si no hay contenedores en la misma visita 
				         				 
							         					     -- fin de busqueda de siguiente posiscion
							         					      ---?? ver si en la siguiente posicion hay contenedores sin marcar?? sino hay , en el bloque hay???, obtener el de la visita menor?
							         					     
							         					     -- contar la cantidad de conteendores sin marcar
							         					     SELECT @lint_pendingconts  = COUNT(strContainer  )
							         					     FROM #ContainersTable
							         					     WHERE strBlock =  @lstr_blockId
							         					     AND ISNULL(intOrderId ,0) =0


							         					  -- incrementar la cantida de iteraciones 
							         					  SET @lint_whileidx = @lint_whileidx +1 

							                              --SET @lstr_message = '856- FIN CICLO PCONT=' + CONVERT(VARCHAR(5),@lint_pendingconts) +'WHILEID='+CONVERT(VARCHAR(5),@lint_whileidx)+'TOP'+CONVERT(VARCHAR(5),@lint_whiletop)
							                             -- PRINT @lstr_message
							                         -- SALIR PRIMERA ITERACION
							                         
							                        -- SELECT * FROM  #ContainersTable ORDER BY intOrderId  DESC 
							                         -- RETURN 0      					  
													    --- fin ciclo revisando , 
													 END --WHILE ( ( @lint_pendingconts>0 ) AND ( @lint_whileidx < @lint_whiletop )  )
													    
									END-- IF (@lint_CountContIdx >=  @lint_mincontfblock )
									
								--ELSE -- IF (@lint_CountContIdx >=  @lint_mincontfblock )
								-- IF (@lint_CountContIdx >=  1)
									--BEGIN
								      -- sino , marcar el bloque con reacomodo, marcar los contenedores con reacomovdo segun la variable de marcacion 								      
								--    END  --ELSE -- IF (@lint_CountContIdx >=  @lint_mincontfblock )							      
						   
							   FETCH  blockcur INTO @lstr_blockId ,  @lint_CountContIdx
							   
							      SET @lint_GBlockC  = @lint_GBlockC  +1 
							      
							   SET @lstr_message = '912- VUELTA CURSOR BK='+ @lstr_blockId+ ' COUNT='+ CONVERT(VARCHAR(5),@lint_CountContIdx)
							   PRINT @lstr_message
							   -- SELECT * FROM  #ContainersTable ORDER BY intOrderId  ASC
							   --RETURN 0
							   
                          end 
                        -- fin ciclo cursor
                   CLOSE blockcur
                   DEALLOCATE CURSOR blockcur
                   ------
	
	  --- fin cursor bloques 
       -- retornar agrupado
       SELECT strBlock , dateTimeMark  , intCrane , intGblok, COUNT(strContainer  )       
       FROM #ContainersTable
       GROUP BY strBlock , dateTimeMark  , intCrane,intGblok 
       ORDER BY intGblok,dateTimeMark  ASC
       
       	  -- retornar tabla resultados 
	  /* Adaptive Server has expanded all '*' elements in the following statement */ SELECT #ContainersTable.intUniversalId, #ContainersTable.strContainer, #ContainersTable.intVisitId, #ContainersTable.intItem, #ContainersTable.strPosition, #ContainersTable.strBlock, #ContainersTable.strBay, #ContainersTable.strRow, #ContainersTable.strStow, #ContainersTable.intMarkTime, #ContainersTable.strTime, #ContainersTable.dateTimeMark, #ContainersTable.intCrane, #ContainersTable.strCraneval, #ContainersTable.intOrderId, #ContainersTable.intGenOrder, #ContainersTable.intGblok FROM  #ContainersTable ORDER BY intGenOrder ASC 
      --

       
      ---
        DROP TABLE #BlockTable
        DROP TABLE #ContainersTable
        DROP TABLE #TimeMarks
        DROP TABLE #CraneList
        DROP TABLE #TimeMarkCraneG
        
	          
	    END -- IF (@intMode  =1)
    
 END  --END CREATE PROCEDURE spSetAppointOnTime







