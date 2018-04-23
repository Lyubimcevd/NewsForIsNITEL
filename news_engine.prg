CREATE CURSOR table_cur(dt V(50),mes M)
str_query = "SELECT CONVERT(VARCHAR, max(dt_order), 120) as dt FROM cvodka.dbo.statistic_menu where zadach like 'ÈÑ ÍÈÒÅË%' and polzovatel = ?family ";
	+"group by polzovatel"
b = SQLEXEC(con_bd1,str_query,'tmp_cur')
str_query = "select * from news_isnitelt where projn != 'òåñò' and dt>'16.03.2018'"
SELECT 'tmp_cur'
IF RECCOUNT()#0
	str_query = str_query + " and dt > '"+STUFF(dt,11,1,'T')+"'"
ENDIF 
str_query = str_query + " order by dt desc"
b = SQLEXEC(con_bd1,str_query,'act_news')
SELECT 'act_news'
SCAN 
	IF ISNULL(towho)
		is_visible = .T.
	ELSE	
		is_visible = .F.
		str_towho = ALLTRIM(towho)+","
		DO while AT(',',str_towho)!= 0
			cur_group_or_user = SUBSTR(str_towho,1,AT(',',str_towho)-1)
			str_towho = SUBSTR(str_towho,AT(',',str_towho)+1)
			str_query = "select * from cvodka.dbo.log_asup_ where vxod is null and loginn = '"+cur_group_or_user+"'"
			b = SQLEXEC(con_bd1,str_query,'tmp_cur')
			SELECT 'tmp_cur'
			IF RECCOUNT()#0
				str_query = "select * from (select l2.loginn as groupn,l.loginn as polz from [cvodka].[dbo].[group_users] gu inner join";
					+" cvodka.dbo.log_asup_ l on l.id=gu.id_u inner join cvodka.dbo.log_asup_ l2 on l2.id=gu.id_g) as tmp where groupn = '";
					+cur_group_or_user+"' and polz = '"+family+"'"
				b = SQLEXEC(con_bd1,str_query,'tmp_cur')
				SELECT 'tmp_cur'
				IF RECCOUNT()#0 
					is_visible = .T.
					exit
				ENDIF		 
			ELSE
				IF cur_group_or_user = family
					is_visible = .T.
					exit
				ENDIF
			ENDIF
		ENDDO
	ENDIF
	IF is_visible
		SELECT 'act_news'  
		str_query = "select CONVERT(VARCHAR, dt, 120) as dt,textn from news_isnitelt where dt = '"+TTOC(dt)+"'"
		b = SQLEXEC(con_bd1,str_query,'tmp_cur')
		SELECT 'tmp_cur'
		cur_dt = ALLTRIM(dt)
		cur_dt =SUBSTR(cur_dt,9,2)+"."+SUBSTR(cur_dt,6,2)+"."+LEFT(cur_dt,4)+" "+LEFT(RIGHT(cur_dt,8),5)
		cur_mes = textn
		INSERT INTO table_cur (dt,mes) VALUES (cur_dt,cur_mes)
	ENDIF
ENDSCAN 
SELECT 'table_cur'
IF RECCOUNT()#0
	DO FORM news WITH 'table_cur'
ENDIF