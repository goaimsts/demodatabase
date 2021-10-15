



--	https://onsitetraining2.aimsasp.net/
--	dbserver02\sql2017.OnsiteTraining2 - AimsWeb04

--	Locations
/*
select * 
from aims.loc as loc
	left join aims.cod as locName on loc.CODE = locName.CODE and (loc.FACILITY = locName.FACILITY or locName.FACILITY = 'MAIN') and locName.[TYPE] = 'o'

--	These are totally generic
*/



/*
select * from aims.PRC
select * from aims.TASK
select * from aims.cod where TYPE='a'
select * from aims.cod where type = 'd'
select * from aims.cod where type = 'j' order by name
select * from aims.cod where type = 'r' order by name
select * from aims.cod where type = 'g' order by name
select * from aims.BLD
select * from aims.LOC
select count(*) as cntPMs from aims.wko where wko.WO_TYPE <> 'PM' and wko.WO_STATUS = 'OP' 
select * from aims.RSK
select * from aims.msched
select * from aims.STATE_MACRO
select * from aims.RMACRO
select * from aims.AREA
select * from aims.SRVC_AREA
select * from aims.CRD
select * from aims.EQU_WARRANTY
select * from aims.sym
select * from aims.REQUEST
select * from aims.PO
select * from aims.LAB_DEPL_CLASS
select * from aims.cnt
select * from aims.EQU_CNT
select * from aims.NOTES
select * from aims.ehrs
select * from aims.PMI
select * from aims.mtr
select * from aims.WKO_SIGNOFF
select * from aims.WO_GROUP
select * from aims.cussetup 
select * from aims.CUSEXPD 
select * from aims.CUSEXPN
select * from aims.document	
select * from aims.DOCUMENT_ATTACHMENT
select * from aims.WAREHOUSE
select * from aims.wrhs 
select * from aims.PROCESS_QUEUE
select * from aims.DIR_ADR
select * from aims.ehrs 
select * from aims.bud 
select * from aims.SPEC
select * from aims.CRD
select * from aims.MANAGER
select * from aims.ECRI_DEVICE
select * from aims.ALERT
select * from aims.ALERT__ECRI_DEVICE
select * from aims.ALERT__EQU
select * from aims.VMODEL_MANUAL
*/





--	Manufacturers
/*

/*
select count(*) from aims.cod where [type] = 'm'

--173 items
*/

select distinct
	 manuf.[NAME]
	,mdx.make_sa
	,case 
		when mdx.make_sa = manuf.[Name] 
			then 'OK' 
		when mdx.make_sa is not null 
			then 'Fix' 
		else 'Manufal fix' 
	 end								as [fix type]
from aims.cod as manuf
	left join aims.mdx2Makes as mdx on manuf.[NAME] = mdx.make_sa
									or (manuf.[NAME] like '%' + mdx.make_sa + '%'
										and 
										manuf.[NAME] <> mdx.make_sa)
									or ('%' + manuf.[NAME] + '%' like mdx.make_sa
										and 
										manuf.[NAME] <> mdx.make_sa)
where 
	manuf.[TYPE] = 'm'
order by manuf.[NAME]

/*
select * from aims.cod where [TYPE] = 'm' and [NAME] = 'steris'
select * from aims.cod where [TYPE] = 'm' and code = '15'
*/

*/








--	Models
/*

;with cte_makeModelUsage(make,model,usage)
as (
		select 
			 equ.MANUFACTUR			as make
			,equ.MODEL_NUM			as model
			,count(equ.TAG_NUMBER)	as usage
		from aims.EQU 
		group by 
			 equ.MANUFACTUR			
			,equ.MODEL_NUM			

)
select distinct
	 vend.[NAME]			as manuf 
	,vm.MODEL
	,etype.[NAME]			as etype
	,mdx.make_sa 
	,mdx.model_sa
	,mmu.usage
from aims.VMODEL as vm 
	join aims.cod as vend on vm.VENDOR = vend.CODE and vend.[TYPE] = 'm'
	left join aims.cod as etype on vm.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	left join aims.mdx2Models as mdx on vm.MODEL = mdx.model_sa 
									and vend.[NAME] = mdx.make_sa
	left join cte_makeModelUsage as mmu on vm.VENDOR = mmu.make 
										and vm.MODEL = mmu.model

*/

/*

--	Fixes to models 
select * from aims.cod where [TYPE] = 'g' and [NAME] = 'aspirators, surgical'

update aims.equ
set equ.[TYPE] = 'ASP-200'
from aims.EQU
	join aims.cod as manuf on equ.MANUFACTUR = manuf.[CODE] and manuf.[TYPE] = 'm'
where 
	manuf.[NAME] = '3com'
	and 
	equ.MODEL_NUM = '83000'
	and 
	equ.[TYPE] = 'ASP-100'

*/

--	Model normalization
/*
 
select 
	 manuf.[NAME]	as manuf
	,vm.MODEL
from aims.VMODEL as vm
	join aims.cod as manuf on vm.VENDOR = manuf.CODE and manuf.[TYPE] = 'm'
order by manuf.[NAME],vm.MODEL

*/











--	Equipment management
--		Is there a model on VModel which matches the equipment item?
 
/*

select distinct
	 eType.[NAME]			as eType 
	,vmType.[NAME]			as vmType
	,eq.DESCRIPTN			as [description]
	,eq.MODEL_NUM			as eModel
	,vm.MODEL				as vmModel
	,eq.EQU_MODEL_NAME		as eModelName 
	,vm.MODEL_NAME			as vmModelName
	,emanuf.[NAME]			as eManuf
	,vmManuf.[NAME]			as vmManuf
	,fac.[NAME]				as facility
	,fac.[CODE]				as facCode
	,eq.TAG_NUMBER
	,bld.[BLD_NAME]			as [building]
	,elocloc.[NAME]			as [location]
	,expd.FIELD17			as [verified]
	,estatus.[NAME]			as [equip status]
from aims.equ				as eq
		left join aims.cod	as eType on eq.[TYPE] = eType.[CODE] and eType.[TYPE] = 'g'
		left join aims.cod	as eManuf on eq.MANUFACTUR = eManuf.[CODE] and emanuf.[TYPE] = 'm'
	left join aims.VMODEL	as vm on eq.MANUFACTUR = vm.VENDOR
								and eq.MODEL_NUM = vm.MODEL
		left join aims.COD	as vmType on vm.[TYPE] = vmType.CODE and vmType.[TYPE] = 'g'
		left join aims.COD	as vmManuf on vm.VENDOR = vmManuf.[CODE] and vmManuf.[TYPE] = 'm'
	left join aims.cod		as cc on eq.COST_CTR = cc.CODE and eq.FACILITY = cc.FACILITY and cc.[TYPE] = 'a'
	left join aims.cod		as fac on eq.FACILITY = fac.[CODE] and fac.[TYPE] = 'y'
	left join aims.expd		as expd on eq.FACILITY = expd.FACILITY and expd.TAG_NUMBER = eq.TAG_NUMBER
	left join aims.ELOC		as eloc on eq.FACILITY = eloc.FACILITY and eq.TAG_NUMBER = eloc.TAG_NUMBER
		left join aims.cod	as elocLoc on eloc.LOC_FIELD2 = elocLoc.CODE	and elocLoc.[TYPE] = 'o'
	left join aims.BLD		as bld on eq.BLD_CODE = bld.BLD_CODE
	left join aims.cod		as estatus on eq.EQU_STATUS = estatus.CODE and estatus.[TYPE] = 's' 
where 
	--vm.VMODEL_ID is null 
	--(	
	--	eManuf.[NAME] like '%siemens%' 
	--	or 
	--	eManuf.[NAME] = 'ge healthcare'
	--) 
	--(
	--	etype.[NAME] like '%defib%'
	--	or
	--	eq.DESCRIPTN like '%defib%'
	--)
	--and
	--expd.FIELD17 <> 'Y'
	--and 
	eq.FACILITY = 'south'			
	--and 
	--eq.EQU_STATUS not in ('my','re')			
order by fac.[name],eType.[NAME],elocloc.[NAME]

*/


/*
delete aims.EQU_CNT_AMEND where FACILITY = 'north' and TAG_NUMBER = '150'


select * from aims.TASK where TASK_NAME like '%heater%'

select equ.TAG_NUMBER
from aims.equ 
where FACILITY = 'north'
order by TAG_NUMBER
*/










--	Numbers by type - SINGLE FACILITY AT A TIME
/*

select 
	 coalesce(etype.[NAME],equ.DESCRIPTN)			as typeDescr
	,count(coalesce(etype.[NAME],equ.DESCRIPTN))	as cntTypeDescr
from aims.equ 
	left join aims.cod		as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
where equ.FACILITY = 'remsit'				
	and 
	etype.[NAME] = 'test equipment'
group by coalesce(etype.[NAME],equ.DESCRIPTN)
order by coalesce(etype.[NAME],equ.DESCRIPTN)

*/










--	Complete Listing
/*

select distinct
	 eType.[NAME]			as eType 
	,eq.DESCRIPTN			as [description]
	,eq.MODEL_NUM			as eModel
	,eq.EQU_MODEL_NAME		as eModelName 
	,emanuf.[NAME]			as eManuf
	,fac.[NAME]				as facility
	,fac.[CODE]				as facCode
	,eq.TAG_NUMBER
	,bld.[BLD_NAME]			as [building]
	,elocloc.[NAME]			as [location]
	,case when vm.VMODEL_ID is not null 
		then 'x'
		else ''
	 end					as [has vmodel]
	,estatus.[NAME]			as [equip status]
	,expd.FIELD17			as [verified]
	,sd.[NAME]				as [Svc Dept]
from aims.equ				as eq
		left join aims.cod	as eType on eq.[TYPE] = eType.[CODE] and eType.[TYPE] = 'g'
		left join aims.cod	as eManuf on eq.MANUFACTUR = eManuf.[CODE] and emanuf.[TYPE] = 'm'
	left join aims.VMODEL	as vm on eq.MANUFACTUR = vm.VENDOR
								and eq.MODEL_NUM = vm.MODEL
	left join aims.cod		as cc on eq.COST_CTR = cc.CODE and eq.FACILITY = cc.FACILITY and cc.[TYPE] = 'a'
	left join aims.cod		as fac on eq.FACILITY = fac.[CODE] and fac.[TYPE] = 'y'
	left join aims.expd		as expd on eq.FACILITY = expd.FACILITY and expd.TAG_NUMBER = eq.TAG_NUMBER
	left join aims.ELOC		as eloc on eq.FACILITY = eloc.FACILITY and eq.TAG_NUMBER = eloc.TAG_NUMBER
		left join aims.cod as elocLoc on eloc.LOC_FIELD2 = elocLoc.CODE	and elocLoc.[TYPE] = 'o'
	left join aims.BLD		as bld on eq.BLD_CODE = bld.BLD_CODE
	left join aims.cod		as estatus on eq.EQU_STATUS = estatus.CODE and estatus.[TYPE] = 's'
	left join aims.COD		as sd on eq.SRVC_DEPT = sd.CODE and sd.[type] = 'v'
where eq.FACILITY = 'north'
order by
	 eType.[NAME]
	,bld.[BLD_NAME]	
	,elocloc.[NAME]	

*/

/*
update aims.equ 
set EQU_STATUS = 'RE'
	,STAT_DATETIME = GETUTCDATE()
where DESCRIPTN = 'PUMP CENTRIFUGAL'

update aims.equ 
set DESCRIPTN = 'Infusion Pump'
from aims.equ 
	join aims.cod as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
where etype.[NAME] = 'Infusion Pump'
	and 
	DESCRIPTN <> 'Infusion Pump'

update aims.equ 
set BLD_CODE = 'CENTER'			
from aims.equ 
where equ.[TYPE] = 'INFPUMP' and facility = 'north'

*/



 








--	Duplicate tags?
/*

select 
	 TAG_NUMBER 
	,count(tag_number)	as cntTags
from aims.equ 
group by TAG_NUMBER
having count(tag_number) > 1
order by TAG_NUMBER

--	There were 4. Fixed.
*/

/*
delete aims.EQU_CNT_AMEND where facility = 'SOUTH' and TAG_NUMBER = '4445'
select * from aims.cod where TYPE = 'y'

select facility,tag_number from aims.equ where TAG_NUMBER in ('4000','anes1') and FACILITY = 'South'
select * from aims.EQU_CNT where FACILITY = 'South' and TAG_NUMBER in ('4000','anes1')
delete aims.EQU_CNT_AMEND where FACILITY = 'South' and TAG_NUMBER in ('4000','anes1')

*/












--	Cleared Locations
/*

update aims.equ 
set LOCATION = NULL 
	,BLD_CODE = null 
from aims.equ as eq
where eq.LOCATION is not null or eq.BLD_CODE is not null 

*/

/*
update aims.WKO 
set LOCATION = null 
	,LOCATION1 = null 
	,location2 = null 
	,location3 = null 
	,location4 = null 
	,location5 = null 
	,BLD_CODE = null 
from aims.wko as wo
where wo.LOCATION is not null 
	or 
	wo.LOCATION1 is not null 
	or 
	wo.LOCATION2 is not null 
	or 
	wo.LOCATION3 is not null
	or 
	wo.LOCATION4 is not null 
	or 
	wo.LOCATION5 is not null 
	or 
	wo.BLD_CODE is not null 
*/


/*

select * from BLD
select * from aims.LOC


delete aims.ELOC 
where LOC_FIELD1 is not null 

*/






--	Cleared all PM Schedules so can push down correct ones
/*

delete aims.PVM

*/








--	Type / Description / PM Procedure
--		At Equipment Level 
/*

select 
	 equ.TAG_NUMBER
	,equ.DESCRIPTN
	,etype.[NAME]			as [equip type]
	,prc.PROC_NAME
from aims.equ as equ
	left join aims.pvm as pvm on equ.FACILITY = pvm.FACILITY and equ.TAG_NUMBER = pvm.TAG_NUMBER
	left join aims.cod as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
		left join aims.prc on pvm.pm_proc = prc.proce
--where equ.facility = 'south'
order by 
	etype.[NAME],equ.TAG_NUMBER

*/


--		At Equipment Type or Level
/*

select 
	 etype.[NAME]			as [equip type]
	,prc.[PROC_NAME]		as [procedure]
from aims.cod				as etype
	left join aims.pmd		as pdm on etype.CODE = pdm.[TYPE] 
		left join aims.prc	as prc on pdm.PM_PROC = prc.PROCE
where etype.[TYPE] = 'g'
	--and 
	--prc.[PROC_NAME] is null 
order by etype.[NAME]

*/

--	Model Procedure usage 
/*

select 
	 etype.[NAME]					as [equip type] 
	,prc.PROC_NAME
	,manuf.[NAME]					as [manuf]
	,vm.MODEL 
from aims.VMODEL					as vm
	left join aims.cod				as etype on vm.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	left join aims.cod				as manuf on vm.VENDOR = manuf.[CODE] and manuf.[TYPE] = 'm'
	left join aims.pmd				as pmd on vm.VENDOR = pmd.VENDOR and vm.MODEL = pmd.MODEL
	left join aims.prc				as prc on pmd.PM_PROC = prc.PROCE
where left(manuf.[NAME],2) >= 'te'
order by manuf.[NAME],etype.[NAME]

*/



--	Find equipment type usage
/*

select 
	 etype.[NAME]		as [equip type]
	,manuf.[NAME]		as [manuf] 
	,vm.*
from aims.VMODEL as vm
	join aims.cod as etype on vm.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	join aims.cod as manuf on vm.VENDOR = manuf.CODE and manuf.[TYPE] = 'm'
order by etype.[NAME]	
where etype.[NAME] = 'scales'

*/







--	Procedure / Task Mismatches
/*

select	
	 p.PROC_NAME
	,pt.TASK_SEQ
	,t.TASK
	,t.TASK_NAME
from aims.prc as p
	join aims.PRC_TSK as pt on p.PROCE = pt.PROCE 
	join aims.TASK as t on pt.TASK = t.TASK
--where p.PROC_NAME = 'Anesthesia Units'
where left(p.PROC_NAME,2) >= 'wa'
order by p.PROC_NAME,pt.TASK_SEQ

select * from aims.task where task_name like '%hour%'

set nocount on
declare @taskToDelete varchar(max) = 'TPOON'
begin try 
	begin tran 
		delete aims.PRC_TSK where task = @taskToDelete 
		print @@rowcount
		delete aims.TASK	where task = @taskToDelete
		print @@rowcount 
	commit tran
end try 
begin catch 
	if @@TRANCOUNT > 0 rollback tran 
	select ERROR_MESSAGE() as errorMessage
end catch 

*/
	





/*

update aims.QUESTION
set TEMPLATE_CODE = 'PANBLG'
where TEMPLATE_CODE = 'PANBL1'

update aims.TEMPLATE
set code = 'panblg'
where CODE = 'PANBL1'

update aims.wko 
set PROC_JOBTY = 'PANBLG'
where PROC_JOBTY = 'PANBL1'

delete aims.PRC_TSK where proce = 'PANBL1'

*/

/*

delete aims.PM_STATUS where PM_PROC in ('panunv','panun1')
delete aims.pmd where PM_PROC in ('panunv','panun1')
delete aims.PRC_TSK where proce  in ('panunv','panun1')
delete aims.pmi where PM_PROC  in ('panunv','panun1')
delete aims.wko where PROC_JOBTY  in ('pnewpr')
delete aims.prc where PROCE in ('pnewpr')

update aims.TEMPLATE 
set code = 'panun'
where code  in ('panunv','panun1')


update aims.question 
set TEMPLATE_CODE = 'panun'
where TEMPLATE_CODE  in ('panunv','panun1')

delete aims.prc_tsk where proce = 'pnewpr'
delete aims.question where template_code = 'pnewpr'
delete aims.pmd where PM_PROC = 'pnewpr'
delete aims.prc where PROCE = 'pnewpr'
delete aims.question where TEMPLATE_CODE = 'pnewpr'
delete aims.TEMPLATE where CODE = 'pnewpr'

*/







--	Types and Models
/*

select 
	 etypes.[NAME]			as [equip type] 
	,manuf.[NAME]			as [manuf]
	,vm.MODEL
	,vm.MODEL_NAME
from aims.cod as etypes
	left join aims.VMODEL	as vm on etypes.CODE = vm.[TYPE]
	left join aims.cod		as manuf on vm.VENDOR = manuf.CODE and manuf.[TYPE] = 'm'
where etypes.[TYPE] = 'g'
order by 
	 etypes.[NAME]			
	,vm.MODEL

select 
	 manuf.[NAME]			as [manuf]	
	,count(vm.VMODEL_ID)	as countModels
from aims.cod as etypes
	left join aims.VMODEL	as vm on etypes.CODE = vm.[TYPE]
	left join aims.cod		as manuf on vm.VENDOR = manuf.CODE and manuf.[TYPE] = 'm'
where etypes.[TYPE] = 'g'
group by manuf.[NAME]	


select 
	 etypes.[name]			as [equip type]	
	,count(vm.VMODEL_ID)	as countModels
from aims.cod as etypes
	left join aims.VMODEL	as vm on etypes.CODE = vm.[TYPE]
	left join aims.cod		as manuf on vm.VENDOR = manuf.CODE and manuf.[TYPE] = 'm'
where etypes.[TYPE] = 'g' 
group by etypes.[name]		
having count(vm.vmodel_id) > 0


*/







--	Manufacturers
/*

select *
from aims.cod 
where [TYPE] = 'm'
order by [NAME]

*/








--	Open PMS
/*

select count(*) 
from aims.WKO
where 
	wko.FACILITY = 'North' 
	and
	--wko.WO_STATUS not in ('cl','ps')
	wko.WO_STATUS = 'op'
	and 
	wko.WO_TYPE = 'pm'

*/







--	Open CMs
/*

select 
	 convert(date,wko.REQST_DATETIME)			as requestDate
	,count(convert(date,wko.REQST_DATETIME))	as countRequestDate 
from aims.WKO
where 
	wko.FACILITY = 'North' 
	and
	wko.WO_STATUS not in ('cl','ps')
	and 
	wko.WO_TYPE <> 'pm'
group by convert(date,wko.REQST_DATETIME)
order by convert(date,wko.REQST_DATETIME)

*/

--	Service Department 
/*

select 
	 etype.[NAME]				as [equip type]
	,sd.[NAME]					as [Svc Dept]
from aims.TYP
	left join aims.cod			as etype on typ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	left join aims.cod			as sd on typ.SRVC_DEPT = sd.CODE and sd.[TYPE] = 'v'
order by etype.[NAME]

*/

--	Equipment / Type by Cost Center / Responsible Center
/*

select 
	 eq.TAG_NUMBER 
	,etype.[NAME]					as [equip type] 
	,cc.[NAME]						as [cost center] 
	,rc.[NAME]						as [resp center]
from aims.EQU						as eq
	join aims.COD					as cc on eq.COST_CTR = cc.CODE and (eq.FACILITY = cc.FACILITY or cc.FACILITY = 'main') and cc.[TYPE] = 'a'
	join aims.COD					as rc on eq.RESP_CTR = rc.CODE and (eq.FACILITY = rc.FACILITY or rc.FACILITY = 'main') and rc.[TYPE] = 'a'
	join aims.cod					as etype on eq.[TYPE] = etype.code and etype.[TYPE] = 'g'
where 
	eq.FACILITY = 'south'
	and 
	left(etype.[name],2) >= 'ai'
order by etype.[NAME]

*/

--	Equipment Building, Cost Center, Responsible Center, Location
/*

select 
	--distinct cc.code,cc.[NAME]

	 eq.TAG_NUMBER 
	,etype.[NAME]			as [equip type]
	,bld.[BLD_NAME]			as building
	,cc.[NAME]				as [cost center]
	,rc.[NAME]				as [resp center]
	,eq.[LOCATION]
	,eq.COST_CTR 
	,eq.RESP_CTR
from aims.equ as eq
	left join aims.cod			as etype on eq.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	left join aims.bld			as bld on eq.BLD_CODE = bld.BLD_CODE
	left join aims.COD			as cc on eq.FACILITY = cc.FACILITY and eq.COST_CTR = cc.CODE and cc.[TYPE] = 'a'
	left join aims.COD			as rc on eq.FACILITY = rc.facility and eq.RESP_CTR = rc.code and rc.[TYPE] = 'a'
where 
	eq.FACILITY = 'north'
	and 
	cc.[NAME] = 'administration'

*/

--/*

--	One-time, reconcile all WO Cost Centers to be the same as the equipment item
/*

update aims.wko 
set CHG_CTR = equ.COST_CTR
from aims.wko as wko 
	join aims.equ as equ on wko.facility = equ.FACILITY and wko.TAG_NUMBER = equ.TAG_NUMBER

*/

/*
set nocount on
declare @accountCode varchar(50) = ''

begin try
	begin tran

		update aims.equ set COST_CTR = '6130' where COST_CTR = @accountCode
		update aims.equ set RESP_CTR = '6130' where RESP_CTR = @accountCode
		update aims.wko set CHG_CTR = '6130' where CHG_CTR = @accountCode
		delete aims.ahrs where account = @accountCode
		delete aims.base_date where base_date.COST_CTR = @accountCode
		delete aims.EN3_USER_CC where COST_CTR = @accountCode
		
		delete aims.adr where CODE = @accountCode
		delete aims.bud where account = @accountCode
		delete aims.act where account = @accountCode
		delete aims.cod where code = @accountCode and [type] = 'a'

	commit tran 
end try 
begin catch 

	if @@TRANCOUNT > 0 rollback tran 
	select error_message() as errorMessage

end catch 
*/

--*/


--	Facility Groups
/*

delete aims.FAC where facility = 'north' and FAC_GROUP = 'Nothern Region Group'
select * from aims.FAC

*/




--	Dates!

/*

select  
	--distinct sd.[NAME]
	 eq.TAG_NUMBER 
	,f.CODE					as [facility code]
	,f.[NAME]				as [facility]
	,etype.[NAME]			as [equip type]
	,bld.[BLD_NAME]			as building
	,sd.[NAME]				as [Svc Dept]
	,prc.PROCE				as [proc code]
	,prc.PROC_NAME
	,pvm.NEXT_DATETIME
	,pvm.FREQUENCY
	,pvm.FREQ_UNIT
from aims.equ as eq
	left join aims.cod			as etype on eq.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	left join aims.bld			as bld on eq.BLD_CODE = bld.BLD_CODE
	left join aims.COD			as cc on eq.FACILITY = cc.FACILITY and eq.COST_CTR = cc.CODE and cc.[TYPE] = 'a'
	left join aims.COD			as rc on eq.FACILITY = rc.facility and eq.RESP_CTR = rc.code and rc.[TYPE] = 'a'
	left join aims.pvm			as pvm on eq.FACILITY = pvm.FACILITY and eq.TAG_NUMBER = pvm.TAG_NUMBER
		left join aims.prc		as prc on pvm.PM_PROC = prc.PROCE
	left join aims.cod			as f on eq.FACILITY = f.CODE and f.[TYPE] = 'y'
	join aims.STA				as sta on eq.EQU_STATUS = sta.[STATUS]
	left join aims.cod			as sd on pvm.SRVC_DEPT = sd.CODE and sd.[TYPE] = 'v'	
where 
	prc.PROC_NAME <> 'Initial Inspection'
	and 
	convert(date,pvm.NEXT_DATETIME) = '9/14/2021'
	and 
	sta.HOLD_PM <> 'Y'
	--and 
	--eq.FACILITY = 'north'
	--etype.[NAME] = 'test equipment'
order by 
	-- f.[NAME]
	--,eq.TAG_NUMBER 
	sd.[NAME]
*/ 



/*

update aims.pvm 
set NEXT_DATETIME = '3/14/2022'
where 
	--FACILITY = ''
	--and 
	TAG_NUMBER in ('te1','te2','te3','te4')

*/

/*

update aims.pvm 
set pvm.NEXT_DATETIME = '9/1/2021 12:00:00.000'
from aims.equ as eq
	left join aims.pvm			as pvm on eq.FACILITY = pvm.FACILITY and eq.TAG_NUMBER = pvm.TAG_NUMBER
		left join aims.prc		as prc on pvm.PM_PROC = prc.PROCE
	left join aims.cod			as f on eq.FACILITY = f.CODE and f.[TYPE] = 'y'
	join aims.STA				as sta on eq.EQU_STATUS = sta.[STATUS]
	left join aims.cod			as etype on eq.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
where 
	prc.PROC_NAME <> 'Initial Inspection'
	and 
	sta.HOLD_PM <> 'Y'
	--and 
	--etype.[NAME] <> 'Test Equipment '
	and 
	eq.facility = 'REMSIT'
print @@rowcount
	
*/ 


--	Get PM's to be created based on Scheduled on/before date - stagger over 12 months (except test equipment)
/*

declare @moveIt table(
	 tag_number		varchar(max)
	,facilityCode	varchar(50)
	,pm_proc		varchar(50)
)

set nocount on

insert into @moveIt
select top 6 --top(8) percent
	 eq.TAG_NUMBER 
	,f.CODE					as [facility code]
	,pvm.PM_PROC
from aims.equ as eq
	left join aims.cod			as etype on eq.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	left join aims.bld			as bld on eq.BLD_CODE = bld.BLD_CODE
	left join aims.COD			as cc on eq.FACILITY = cc.FACILITY and eq.COST_CTR = cc.CODE and cc.[TYPE] = 'a'
	left join aims.COD			as rc on eq.FACILITY = rc.facility and eq.RESP_CTR = rc.code and rc.[TYPE] = 'a'
	left join aims.pvm			as pvm on eq.FACILITY = pvm.FACILITY and eq.TAG_NUMBER = pvm.TAG_NUMBER
		left join aims.prc		as prc on pvm.PM_PROC = prc.PROCE
	left join aims.cod			as f on eq.FACILITY = f.CODE and f.[TYPE] = 'y'
	join aims.STA				as sta on eq.EQU_STATUS = sta.[STATUS]
	left join aims.cod			as sd on pvm.SRVC_DEPT = sd.CODE and sd.[TYPE] = 'v'	
where 
	prc.PROC_NAME <> 'Initial Inspection'
	and 
	sta.HOLD_PM <> 'Y' 
	and 
	eq.FACILITY = 'REMSIT'						--select * from aims.cod where TYPE='y' order by name 
	and 
	etype.[NAME] <> 'Test Equipment'
	and 
	convert(date,pvm.NEXT_DATETIME) = '9/1/2021'
order by 
	 eq.SERIAL_NUM
print @@rowcount

update aims.pvm 
set NEXT_DATETIME = dateadd(month,11,NEXT_DATETIME)
from aims.PVM		as pvm
	join @moveIt	as mi on pvm.FACILITY = mi.facilityCode and pvm.TAG_NUMBER = mi.tag_number and pvm.PM_PROC = mi.pm_proc
print @@rowcount

--select * from aims.pvm where NEXT_DATETIME > '9/1/2021'

*/

--		Verify distribution
/*

select 
	 count(distinct eq.TAG_NUMBER)			as countByGenDate 
	,pvm.NEXT_DATETIME
	,sd.[NAME]
	,convert(varchar(50),pvm.NEXT_DATETIME,101)
from aims.equ as eq
	left join aims.cod			as etype on eq.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	left join aims.pvm			as pvm on eq.FACILITY = pvm.FACILITY and eq.TAG_NUMBER = pvm.TAG_NUMBER
		left join aims.prc		as prc on pvm.PM_PROC = prc.PROCE
	left join aims.cod			as f on eq.FACILITY = f.CODE and f.[TYPE] = 'y'
	join aims.STA				as sta on eq.EQU_STATUS = sta.[STATUS]
	left join aims.cod			as sd on pvm.SRVC_DEPT = sd.CODE and sd.[TYPE] = 'v'	
where 
	prc.PROC_NAME <> 'Initial Inspection'
	and 
	sta.HOLD_PM <> 'Y' 
	and 
	prc.[STATUS] = 'Y'
	and 
	eq.FACILITY = 'south'		--= 'REMSIT'	select * from aims.cod where type='y' order by [name]
	--and 
	--etype.[NAME] <> 'Test Equipment'
	--and 
	--pvm.NEXT_DATETIME = '9/1/2021'
group by convert(varchar(50),pvm.NEXT_DATETIME,101),pvm.NEXT_DATETIME,sd.[NAME]
order by pvm.NEXT_DATETIME




*/



--	How many equipment items?
/*

select 
	 count(*)		as countEquipItems
	,equ.FACILITY
from aims.equ 
	join aims.STA on equ.EQU_STATUS = sta.[STATUS]
where sta.HOLD_PM <> 'Y'
group by equ.FACILITY

*/


--	Remove PMs so can fix schedules
/*

delete aims.wko where wko.WO_TYPE = 'pm' and wko.WO_STATUS = 'op' and convert(date,reqst_DATETIME) >= '9/1/2021' and facility = 'remsit' 

*/
--	Review schedules
/*

select 
	 *
from aims.pvm 
where tag_number = '1000'

*/

--		Fix Graceperiods
/*
update aims.pvm 
set GRACE = 1
	,GRACE_TYPE = 'M'
*/

--		Fix next date to be the first of the month
/*
select 
	 FREQ_UNIT
	,FREQUENCY
	,GRACE
	,GRACE_TYPE
	,convert(varchar(50),NEXT_DATETIME,101)	as nextDate
	,NEXT_DATETIME
	,convert(varchar(2),datepart(month,NEXT_DATETIME)) + '/1/' + convert(varchar(4),datepart(year,NEXT_DATETIME)) + ' 12:00:00.000'
from aims.PVM
where datepart(day,next_datetime) <> 1


update aims.pvm 
set NEXT_DATETIME = convert(varchar(2),datepart(month,NEXT_DATETIME)) + '/1/' + convert(varchar(4),datepart(year,NEXT_DATETIME)) + ' 00:00:00.000'
where datepart(day,next_datetime) <> 1
*/

/*
update aims.pvm 
set NEXT_DATETIME = convert(varchar(50),convert(date,next_datetime)) + ' 12:00:00.000'
*/


--	Update contacts
/*

update aims.CUSEMAIL
set		 CONTACT	= '800-555-1212'
		,[ADDRESS]	= replace(NAME,' ','') + '@nwheartinstitute.org'

*/


--	Risk Analysis / cleanup
--		Cost Center Environment Risk
/*

select 
	 fac.[NAME]			as [facility]
	,cc.[NAME]			as [cost center] 
	,act.RISK_0
	,act.risk_5
from aims.ACT
	join aims.cod	as cc on act.ACCOUNT = cc.CODE and (act.FACILITY = cc.FACILITY or cc.FACILITY = 'MAIN') and cc.[TYPE] = 'a'
	join aims.cod	as fac on act.FACILITY = fac.CODE and fac.[TYPE] = 'y'
order by 
	 fac.[NAME]			
	,cc.[NAME]			
	,act.RISK_0
	,act.risk_5

*/

--		Equipment Type usage for setting risk at this level
/*

select distinct etype.[NAME] 
from aims.EQU 
	join aims.cod	as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
where equ.FACILITY = 'south'	--select * from aims.cod where type='y' order by name
order by etype.[NAME]

*/

--		Review of equipment risk / location 
/*

select
	 equ.TAG_NUMBER
	,equ.DESCRIPTN 
	,etype.[NAME]			as [equip type] 
	,cc.[NAME]				as [cost center]
	,rc.[NAME]				as [resp center]
	,equ.INC_FACTOR		
from aims.equ 
	left join aims.COD		as etype on equ.[TYPE] = etype.code and etype.[TYPE] = 'g'
	left join aims.cod		as cc on equ.COST_CTR = cc.CODE and equ.FACILITY = cc.FACILITY and cc.[TYPE] = 'a'
	left join aims.COD		as rc on equ.RESP_CTR = rc.code and equ.FACILITY = rc.FACILITY and rc.[TYPE] = 'a'
order by etype.[NAME],cc.[NAME]

*/


--	Documents and attachments
/*

select 
	 d.[DESCRIPTION]
	,d.[NAME]						as [File Name]
	,da.RECORD_TYPE
	,da.RECORD_ID
	,facility.[NAME]
from aims.DOCUMENT					as d
	join aims.DOCUMENT_ATTACHMENT	as da on d.DOCUMENT_ID = da.DOCUMENT_ID
	join aims.COD					as facility on da.FACILITY = facility.CODE and facility.[TYPE] = 'y'

where d.document_id = 6

order by d.[NAME]

*/

/*
select * from aims.DOCUMENT where [NAME] = 'chiller.jpg'
begin tran 

	delete from aims.DOCUMENT_ATTACHMENT where DOCUMENT_ID = 6

	delete aims.DOCUMENT
	where [NAME] = 'chiller.jpg' 

	commit tran
*/

--	Manuf's with models
/*

select 
	 manuf.[NAME] 
	,vm.MODEL 
	,vm.MODEL_NAME
	,vm.[DESCRIPTION]
	,count(tag_number)					as countEquip
	,count(distinct da.document_attachment_ID)	as attachments
from aims.VMODEL	as vm 
	join aims.cod	as manuf on vm.VENDOR = manuf.CODE and manuf.[TYPE] = 'm'
	join aims.equ	as eq on vm.VENDOR = eq.MANUFACTUR and vm.MODEL = eq.MODEL_NUM
	left join aims.DOCUMENT_ATTACHMENT as da on vm.VMODEL_ID = da.RECORD_ID and RECORD_TYPE = 'model'
group by 
	 manuf.[NAME] 
	,vm.MODEL 
	,vm.MODEL_NAME
	,vm.[DESCRIPTION]
order by manuf.[NAME]

*/

--	Clear all attachments EXCEPT non-OneSource
/*

select distinct 
	 da.DOCUMENT_ATTACHMENT_ID
from aims.DOCUMENT as d
	left join aims.DOCUMENT_ATTACHMENT as da on d.DOCUMENT_ID = da.DOCUMENT_ID
where d.[DESCRIPTION] not like 'https:%'

begin tran 
delete aims.DOCUMENT_ATTACHMENT
from aims.DOCUMENT as d
	join aims.DOCUMENT_ATTACHMENT as da on d.DOCUMENT_ID = da.DOCUMENT_ID
where d.[DESCRIPTION] not like 'https:%'

commit tran

select distinct 
	d.*
from aims.DOCUMENT as d
	left join aims.DOCUMENT_ATTACHMENT as da on d.DOCUMENT_ID = da.DOCUMENT_ID
where d.[DESCRIPTION] not like 'https:%'

delete aims.DOCUMENT
from aims.DOCUMENT as d
where d.[DESCRIPTION] not like 'https:%'

*/










--	Cost Centers HOH
/*

select 
	 facility.[name]						as facility
	,cc.[NAME]								as [cost center] 
	,convert(time,ahrs.SUN_BEG_DATETIME)	as sunBegin
	,convert(time,ahrs.SUN_END_DATETIME)	as sunEnd
	,convert(time,ahrs.MON_BEG_DATETIME)	as monBegin
	,convert(time,ahrs.MON_END_DATETIME)	as monEnd
	,convert(time,ahrs.TUE_BEG_DATETIME)	as tueBegin
	,convert(time,ahrs.TUE_END_DATETIME)	as tueEnd
	,convert(time,ahrs.WED_BEG_DATETIME)	as wedBegin
	,convert(time,ahrs.WED_END_DATETIME)	as wedEnd
	,convert(time,ahrs.THU_BEG_DATETIME)	as thuBegin
	,convert(time,ahrs.THU_END_DATETIME)	as thuEnd
	,convert(time,ahrs.FRI_BEG_DATETIME)	as friBegin
	,convert(time,ahrs.FRI_END_DATETIME)	as friEnd
	,convert(time,ahrs.SAT_BEG_DATETIME)	as satBegin
	,convert(time,ahrs.SAT_END_DATETIME)	as satEnd
	,ahrs.*
from aims.AHRS
	join aims.cod	as facility on AHRS.FACILITY = facility.CODE and facility.[TYPE] = 'y'
	join aims.COD	as cc on ahrs.FACILITY = cc.FACILITY and ahrs.ACCOUNT = cc.[CODE] and cc.[TYPE] = 'a'

*/


--	Acquisition / life-cycle data
/*
select distinct
	-- fac.[NAME]						as facility 
	--,equ.TAG_NUMBER					as [tag #]
	--,manuf.[NAME]					as [manuf]
	etype.[NAME]					as [equip type]
	--,equ.DESCRIPTN					as [description]
	--,equ.model_num					as [model #]
	--,equ.EQU_MODEL_NAME				as [model name]
	--,estatus.[NAME]					as [equ status]
	,equ.[TYPE]						as [equ type code]
	,eClass.[NAME]					as [equ class]
	--,equ.PURCH_COST
	--,equ.AVG_COST
	--,equ.SALVAGE_VALUE
	--,equ.REPLACEMENT_COST
	--,equ.CRITICAL
	--,equ.REPLACEMENT_DATETIME
	--,equ.SALVAGE_DATETIME
	--,supplier.[NAME]				as [supplier]
	--,own.OWNERSHIP_CODE
	--,own.OWNERSHIP_NAME
	--,ish.[HIPAA]
	--,ish.[CAPABLE_EPHI]
	--,ish.[USED_EPHI]
	--,ish.[CAPABLE_LOGON_COMPLIANCE]
	--,ish.[USED_LOGON_COMPLIANCE]
	--,ish.[CAPABLE_PASSWORD_COMPLIANCE]
	--,ish.[USED_PASSWORD_COMPLIANCE]
	--,ish.[CAPABLE_AUTO_LOGOFF]
	--,ish.[USED_AUTO_LOGOFF]
	--,ish.[CAPABLE_ENCRYPTION]
	--,ish.[USED_ENCRYPTION]
	--,ish.[CAPABLE_AUDIT]
	--,ish.[USED_AUDIT]
	--,lif.SALVAGE_VALUE
	--,lif.SALVAGE_DATETIME
	--,lif.REPLACEMENT_COST
	--,lif.REPLACEMENT_DATETIME
from aims.EQU
	join aims.cod					as fac on equ.FACILITY = fac.CODE and fac.[TYPE] = 'y'
	join aims.cod					as eStatus on equ.EQU_STATUS = eStatus.CODE and eStatus.[TYPE] = 's'
	join aims.cod					as manuf on equ.MANUFACTUR = manuf.CODE and manuf.[TYPE] = 'm'
	left join aims.COD				as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
		left join aims.TYP			as et on equ.[TYPE] = et.[TYPE]
			left join aims.cod		as eClass on et.CLASS = eClass.CODE and eClass.[TYPE] = 'c'
	left join aims.cod				as supplier on equ.SUPPLIER = supplier.CODE 
										and (equ.FACILITY = supplier.FACILITY or supplier.FACILITY = 'MAIN')
										and supplier.[TYPE] = 'd'
	left join aims.[OWNERSHIP]		as own on equ.[OWNERSHIP] = own.OWNERSHIP_CODE and (equ.FACILITY = own.FACILITY or own.FACILITY = 'Main')
	left join aims.IS_EQUIP			as ise on equ.FACILITY = ise.FACILITY and equ.TAG_NUMBER = ise.TAG_NUMBER
		left join aims.IS_HIPAA		as ish on ise.IS_EQUIP_ID = ish.IS_EQUIP_ID
	left join aims.LIFE				as lif on equ.FACILITY = lif.FACILITY and equ.TAG_NUMBER = lif.TAG_NUMBER
	left join aims.VMODEL			as vm on equ.MANUFACTUR = vm.VENDOR and equ.MODEL_NUM = vm.MODEL
--where eClass.[NAME]	 is null
order by etype.[NAME]	
*/



/*

update aims.LIFE
set EQU_CLASS = etype.CLASS
from aims.LIFE
	join aims.EQU as equ on life.FACILITY = equ.FACILITY and life.TAG_NUMBER = equ.TAG_NUMBER 
	join aims.TYP as etype on equ.[TYPE] = etype.[TYPE]
	join aims.cod as eclass on etype.CLASS = eclass.CODE and eclass.[TYPE] = 'c'
	join aims.COD as etypeName on etype.[TYPE] = etypeName.CODE and etypeName.[TYPE] = 'g'

update aims.TYP
set CLASS = 'TE'
where type	= 'PRESSUR'

update aims.typ
set CLASS = NULL

update aims.equ 
set [OWNERSHIP] = 'OWNED'
where [OWNERSHIP] is null
 
update aims.equ 
set SUPPLIER = potentialSupplier.CODE
from aims.equ 
	join aims.COD			as manufName on equ.MANUFACTUR = manufName.CODE and manufName.[TYPE] = 'm'
	join aims.cod			as potentialSupplier on manufName.[NAME] = potentialSupplier.[NAME] and potentialSupplier.[TYPE] = 'm'
		join aims.VENDOR	as potSupVendor on potentialSupplier.CODE = potSupVendor.VENDOR and potSupVendor.IS_SUP = 'Y'

*/

/*
update aims.equ 
set AVG_COST = 'Y'
*/

/*
update aims.equ 
set CRITICAL =	case when etype.[NAME] in ('Analyzer, Blood Gas','C-ARM','Heart-Lung Bypass Units','Pumps, Blood')
					then 'Y'
					else 'N'
				end
from aims.equ 
	left join aims.COD				as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
*/

/*
select 
	 etype.[NAME]
	,PHYS_LIFE
	,DEP_LIFE
from aims.TYP
	join aims.cod as etype on typ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
where PHYS_LIFE > 0
	and DEP_LIFE > 0
	and DEP_LIFE > PHYS_LIFE
*/


/*

update aims.equ 
set  purch_cost			= 1850 
	,avg_cost			= 'Y'
	,replacement_cost	= 3800
	,
where equ.DESCRIPTN = 'Infusion Pump'
*/


/*
select 
	 sd.[NAME]
	,spec.*
from aims.SPEC
	left join aims.cod	as sd on spec.SRVC_DEPT = sd.code and sd.[TYPE] = 'v'
order by sd.[NAME]

update aims.SPEC
set spec = 'MRI'
where spec_code = 8
*/

/*	--this is next! 
select * from IS_HIPAA
select h_create... from vmodel
*/



--	IS - Create base is_equip record for all items which don't have it
/*
insert into aims.IS_EQUIP
(
	 FACILITY
	,TAG_NUMBER
	,FDA_DEVICE
)
select 
	 FACILITY
	,TAG_NUMBER
	,''				as FDA_DEVICE
from aims.equ as e 
where 
	not exists	(
					select 
						*
					from aims.equ				as equ
						join aims.IS_EQUIP		as ise on equ.FACILITY = ise.FACILITY and equ.TAG_NUMBER = ise.TAG_NUMBER
					where equ.FACILITY = e.FACILITY and equ.TAG_NUMBER = e.TAG_NUMBER
				)
*/


--	IS - create HIPAA record for all equipment items which do not have it
/*
--select * from aims.IS_HIPAA
insert into aims.IS_HIPAA
(
	IS_EQUIP_ID
)
select 
	 ise.IS_EQUIP_ID
from aims.equ as e
	join aims.IS_EQUIP as ise on e.FACILITY = ise.FACILITY and e.TAG_NUMBER = ise.TAG_NUMBER
where 
	not exists	(
					select * 
					from aims.equ			as equ
						join aims.IS_EQUIP	as ise on e.FACILITY = ise.FACILITY and e.TAG_NUMBER = ise.TAG_NUMBER
						join aims.IS_HIPAA	as ish on ise.IS_EQUIP_ID = ish.IS_EQUIP_ID
					where e.FACILITY = equ.FACILITY and e.TAG_NUMBER = equ.TAG_NUMBER
				)
*/

/*
update aims.IS_HIPAA
set  HIPAA								= 'Y' 
    ,[CAPABLE_EPHI]						= 'Y'
    ,[USED_EPHI]						= 'N'

    ,[CAPABLE_LOGON_COMPLIANCE]			= 'N'
    ,[USED_LOGON_COMPLIANCE]			= 'N'
    ,[CAPABLE_PASSWORD_COMPLIANCE]		= 'N'
    ,[USED_PASSWORD_COMPLIANCE]			= 'N'
    ,[CAPABLE_AUTO_LOGOFF]				= 'N'
    ,[USED_AUTO_LOGOFF]					= 'N'
    ,[CAPABLE_ENCRYPTION]				= 'Y'
    ,[USED_ENCRYPTION]					= 'Y'
    ,[CAPABLE_AUDIT]					= 'N'
    ,[USED_AUDIT]						= 'N'

from aims.IS_HIPAA			as ish
	join aims.IS_EQUIP		as ise on ish.IS_EQUIP_ID = ise.IS_EQUIP_ID
	join aims.equ			as equ on ise.FACILITY = equ.FACILITY and ise.TAG_NUMBER = equ.TAG_NUMBER
	join aims.COD			as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
where etype.[NAME] = 'Vital Signs Acquisition Unit'

select distinct 
	 etype.[NAME]			as [equ type] 
from aims.IS_HIPAA			as ish
	join aims.IS_EQUIP		as ise on ish.IS_EQUIP_ID = ise.IS_EQUIP_ID
	join aims.equ			as equ on ise.FACILITY = equ.FACILITY and ise.TAG_NUMBER = equ.TAG_NUMBER
	join aims.COD			as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
where ish.HIPAA is null 
order by etype.[NAME]
*/

/*
update aims.VMODEL
set	 H_CREATE		= 'Y'
	,H_INTEGRITY	= 'N'
	,H_PRIVACY		= 'N'
	,H_STORE		= 'Y'
	,H_TRANSMITS	= 'N'
	,CRITICAL_ALARM	= 'N'
	,CRITICAL		= 'N'
where vmodel.[TYPE] = 'MOBUNIT'

select distinct 
	 etype.[NAME]			as [equ type]
	,etype.CODE				as [equ type code]
	,ish.HIPAA
	,ish.CAPABLE_EPHI
	,ish.USED_EPHI
	,vm.H_CREATE
from aims.VMODEL			as vm
	join aims.equ			as equ on vm.VENDOR = equ.MANUFACTUR and vm.MODEL = equ.MODEL_NUM
	join aims.IS_EQUIP		as ise on equ.FACILITY = ise.FACILITY and equ.TAG_NUMBER = ise.TAG_NUMBER
	join aims.IS_HIPAA		as ish on ise.IS_EQUIP_ID = ish.IS_EQUIP_ID
	join aims.COD			as etype on vm.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
where isnull(vm.H_CREATE,'') = ''
	--and 
	--ish.HIPAA = 'N'
*/


--	Equipment Class with Types
/*
select distinct
	 ec.[NAME]			as [equip class] 
	,etName.[NAME]		as [equip type] 
from aims.equ			as equ
	join aims.VMODEL	as vm on equ.MANUFACTUR = vm.VENDOR and equ.MODEL_NUM = vm.MODEL
	join aims.TYP		as etype on vm.[TYPE] = etype.[TYPE]
	join aims.cod		as etName on vm.[TYPE] = etName.CODE and etName.[TYPE] = 'g' 
	join aims.cod		as ec on etype.CLASS = ec.CODE and ec.[TYPE] = 'c'
order by ec.[NAME],etName.[NAME]
*/


--	Added Hours of Operation to equipment using CC (where HOH records did not exist)
/*
INSERT INTO [aims].[EHRS]
           ([TAG_NUMBER]
           ,[FACILITY]
           ,[TIME_ZONE]
           ,[TYPE]
           ,[TYPE_FACILITY]
           ,[FRI_BEG_DATETIME]
           ,[FRI_END_DATETIME]
           ,[MON_BEG_DATETIME]
           ,[MON_END_DATETIME]
           ,[S_FRI_BEG_DATETIME]
           ,[S_FRI_END_DATETIME]
           ,[S_MON_BEG_DATETIME]
           ,[S_MON_END_DATETIME]
           ,[S_SAT_BEG_DATETIME]
           ,[S_SAT_END_DATETIME]
           ,[S_SUN_BEG_DATETIME]
           ,[S_SUN_END_DATETIME]
           ,[S_THU_BEG_DATETIME]
           ,[S_THU_END_DATETIME]
           ,[S_TUE_BEG_DATETIME]
           ,[S_TUE_END_DATETIME]
           ,[S_WED_BEG_DATETIME]
           ,[S_WED_END_DATETIME]
           ,[SAT_BEG_DATETIME]
           ,[SAT_END_DATETIME]
           ,[SUN_BEG_DATETIME]
           ,[SUN_END_DATETIME]
           ,[THU_BEG_DATETIME]
           ,[THU_END_DATETIME]
           ,[TUE_BEG_DATETIME]
           ,[TUE_END_DATETIME]
           ,[WED_BEG_DATETIME]
           ,[WED_END_DATETIME])
select										--select * from aims.EHRS
            equ.TAG_NUMBER					--<ACCOUNT, varchar(50),>
           ,equ.FACILITY					--<FACILITY, varchar(6),>
		   ,'GMT'
           ,'e'								--[TYPE]
           ,equ.[FACILITY]
           ,ccHrs.FRI_BEG_DATETIME			-- <FRI_BEG_DATETIME, datetime,>
           ,cchrs.FRI_END_DATETIME			--<FRI_END_DATETIME, datetime,>
           ,ccHrs.MON_BEG_DATETIME			--<MON_BEG_DATETIME, datetime,>
           ,ccHrs.MON_END_DATETIME			--<MON_END_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_FRI_BEG_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_FRI_END_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_MON_BEG_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_MON_END_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_SAT_BEG_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_SAT_END_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_SUN_BEG_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_SUN_END_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_THU_BEG_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_THU_END_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_TUE_BEG_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_TUE_END_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_WED_BEG_DATETIME, datetime,>
           ,'1900-01-01 05:00:00.000'		--<S_WED_END_DATETIME, datetime,>
           ,ccHrs.SAT_BEG_DATETIME			--<SAT_BEG_DATETIME, datetime,>
           ,ccHrs.SAT_END_DATETIME			--<SAT_END_DATETIME, datetime,>
           ,cchrs.SUN_BEG_DATETIME			--<SUN_BEG_DATETIME, datetime,>
           ,ccHrs.SUN_END_DATETIME			--<SUN_END_DATETIME, datetime,>
           ,ccHrs.THU_BEG_DATETIME			--<THU_BEG_DATETIME, datetime,>
           ,ccHrs.THU_END_DATETIME			--<THU_END_DATETIME, datetime,>
           ,ccHrs.TUE_BEG_DATETIME			--<TUE_BEG_DATETIME, datetime,>
           ,ccHrs.TUE_END_DATETIME			--<TUE_END_DATETIME, datetime,>
           ,ccHrs.WED_BEG_DATETIME			--<WED_BEG_DATETIME, datetime,>
           ,ccHrs.WED_END_DATETIME			--<WED_END_DATETIME, datetime,>)
from aims.equ		as equ
	join aims.AHRS	as ccHrs on equ.COST_CTR = ccHrs.ACCOUNT and equ.FACILITY = ccHrs.FACILITY
where 
	not exists	(
					select *
					from aims.ehrs 
					where facility = equ.FACILITY 
						and 
						TAG_NUMBER = equ.TAG_NUMBER
				)
*/


--	Added Hours of Operation to equipment using CC (where HOH records DID exist - update)
/*

update aims.EHRS 
set	 FRI_BEG_DATETIME	= ccHrs.FRI_BEG_DATETIME
	,FRI_END_DATETIME	= ccHrs.FRI_END_DATETIME		
	,MON_BEG_DATETIME	= ccHrs.MON_BEG_DATETIME
	,MON_END_DATETIME	= ccHrs.MON_END_DATETIME
	,SAT_BEG_DATETIME	= ccHrs.SAT_BEG_DATETIME
	,SAT_END_DATETIME	= ccHrs.SAT_END_DATETIME
	,SUN_BEG_DATETIME	= cchrs.SUN_BEG_DATETIME
	,SUN_END_DATETIME	= ccHrs.SUN_END_DATETIME
	,THU_BEG_DATETIME	= cchrs.THU_BEG_DATETIME
	,THU_END_DATETIME	= cchrs.THU_END_DATETIME
	,TUE_BEG_DATETIME	= cchrs.TUE_BEG_DATETIME
	,TUE_END_DATETIME	= cchrs.TUE_END_DATETIME
	,WED_BEG_DATETIME	= cchrs.WED_BEG_DATETIME
	,WED_END_DATETIME	= cchrs.WED_END_DATETIME
from aims.equ		as equ
	join aims.AHRS	as ccHrs on equ.COST_CTR = ccHrs.ACCOUNT and equ.FACILITY = ccHrs.FACILITY
	join aims.ehrs	as ehrs on equ.FACILITY = ehrs.FACILITY and equ.TAG_NUMBER = ehrs.TAG_NUMBER

*/


--	Add Meter readings
/*

select  
	 fac.[NAME]							as facility
	,fac.CODE
	,equ.TAG_NUMBER						as [tag number]
	,etype.[NAME]						as [equip type]
	,convert(date,equ.INSVC_DATETIME)	as inservice
from aims.equ 
	join aims.cod	as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	join aims.cod	as fac on equ.FACILITY = fac.CODE and fac.[TYPE] = 'y'
where 
	etype.[NAME] like 'ventilator%'
	and 
	not exists	(
					select *
					from 
					(
					select sum(mtr) as sumMtr
					from aims.wko 
					where 
						facility = equ.FACILITY 
						and 
						TAG_NUMBER = equ.TAG_NUMBER
					) sumMtr
					where sumMtr.sumMtr > 0
				)
order by etype.[NAME]

select * from aims.MTR where FACILITY = 'north' and TAG_NUMBER = 'vent1'

select 
	 wko.WO_NUMBER
	,wko.FACILITY
	,wko.TAG_NUMBER
	,wko.REQST_DATETIME
	,wko.MTR
	,wko.FREQ_UNIT
from aims.wko 
where facility = 'REMSIT' and TAG_NUMBER = 'vent4'
order by wko.REQST_DATETIME


update aims.wko 
set MTR = 6185
where FACILITY = 'North'
	and 
	WO_NUMBER = 7234

*/



--	Managers
/*
select 
	 mgr.MANAGER		as [isManager]
	,mgrName.[NAME]		as [manager]
	,empName.[NAME]		as [employee]
from aims.MANAGER as m 
	join aims.EMP as mgr on m.MAN_FACILITY = mgr.FACILITY and m.MANAGER = mgr.EMPLOYEE
	join aims.COD as mgrName on mgr.FACILITY = mgrName.FACILITY and mgr.MANAGER = mgrName.CODE and mgrName.[TYPE] = 'e'
	join aims.cod as empName on m.EMP_FACILITY = empName.FACILITY and m.EMPLOYEE = empName.CODE and empName.[TYPE] = 'e'
order by m.manager,m.[SEQUENCE]
*/




/*
select * 
from emp 
where Employee = '00002'
	and 
	facility = 'north'

--	Fixed Johnson, Walter J at North (heart hospital)
update aims.emp 
set TRADE = ''
	,BEEPER_PH = ''
	,BEEPER_NUM = ''
	,MED_REC = ''
	,PAY_SCHED = ''
	,USER_LOGON = ''
	,[SHIFT]	= ''
	,TITLE = ''
	,PHOTO = ''
	,BADGE = ''
	,MOBILE_TYPE = ''
	,BAUD = ''
	,[MESSAGE] = ''
	,EMP_BIO = ''
where Employee = '00002'
	and 
	facility = 'north'
*/


--	Use this with data import into BJC Test db to match with WO's
/*
select distinct 
	etype.[NAME]
from aims.equ 
	join aims.cod as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
*/

--select * from aims.zzEquipTypeProblems

/*
alter table aims.zzEquipTypeProblems
add demoTypeCode varchar(50)
*/

/*
update aims.zzEquipTypeProblems
set demoTypeCode = etype.CODE
from aims.zzEquipTypeProblems	as etp
	join aims.cod				as etype on etp.demoTypeName = etype.[NAME] and etype.[TYPE] = 'g'
*/


--select * from aims.zzEquipTypeProblems where isnull(donotuse,0) = 0 order by [PROBLEM]

/*
update aims.zzEquipTypeProblems
set doNotUse = 1
where problem like ' Sold to%'
*/

/*
update aims.zzEquipTypeProblems
set problem	 = replace(problem,'"','')
where PROBLEM like '%"%'
*/

/*
select 
	 demoTypeName 
	,count(PROBLEM)	as countProblems
from aims.zzEquipTypeProblems
where isnull(doNotUse,0) = 0
group by demoTypeName
order by demoTypeName 


select 
	 demoTypeName 
	,PROBLEM
from aims.zzEquipTypeProblems
where isnull(doNotUse,0) = 0
order by demoTypeName,PROBLEM

select 
	 fac.[NAME]			as facility 
	,equ.TAG_NUMBER		as [tag #]
	,etype.[NAME]		as [equip type]
from aims.equ			as equ
	join aims.STA		as eStatus on equ.EQU_STATUS = eStatus.[STATUS]
	join aims.COD		as fac on equ.FACILITY = fac.CODE and fac.[TYPE] = 'y'
	left join aims.cod	as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
where isnull(eStatus.HOLD_PM,'N') = 'N'
order by fac.[NAME],etype.[NAME],equ.TAG_NUMBER

*/



--	Warranties at Model Level (being used only) set, push down to equipment 
/*
select distinct
	 vm.VMODEL_ID
	,etype.[NAME]	as [equip type]
	,vm.MODEL
	,vm.MODEL_NAME
	,convert(decimal(9,2),0)			as warrantyPeriodYears
into #warranties
from aims.VMODEL	as vm 
	join aims.equ	as equ on vm.VENDOR = equ.MANUFACTUR and vm.MODEL = equ.MODEL_NUM
	join aims.COD	as etype on vm.[TYPE] = etype.code and etype.[TYPE] = 'g'
order by etype.[NAME]
*/


/*
select * from #warranties where warrantyPeriodYears = 1 order by [equip type]

update #warranties
set warrantyPeriodYears = .5
where VMODEL_ID in (54,1091,1106,1105,1107,1071,42,1068,1088,4647,1066,1120,1064,1065)
*/



--select * from aims.COVERAGE

/*
INSERT INTO [aims].[VMODEL_WARRANTY]
           ([VMODEL_ID]
           ,[COVERAGE_ID]
           ,[FREQUENCY]
           ,[FREQ_UNIT]
           ,[NOTE]
           ,[EXPIRE_DATETIME])
select
            w.VMODEL_ID
           ,3						--<COVERAGE_ID, int,>
           ,case when warrantyPeriodYears < 1
				then 6 
				else warrantyPeriodYears
			end						--<FREQUENCY, int,>
           ,case when warrantyPeriodYears < 1 
				then 'M' 
				else 'Y'
			end						--<FREQ_UNIT, varchar(1),>
           ,NULL					--<NOTE, varchar(1000),>
           ,'2499-01-01 00:00:00.000'	--<EXPIRE_DATETIME, datetime,>
from #warranties as w
*/

--	Get Mfg/Model in use for pushing the warranty info down to equipment 
/*

select distinct
	 manuf.[NAME]		as manuf
	,etype.[NAME]		as [equip type]
	,vm.MODEL
	,vm.MODEL_NAME
	,vmw.FREQUENCY
	,vmw.FREQ_UNIT
	,vmw.COVERAGE_ID
from aims.VMODEL	as vm 
	join aims.equ	as equ on vm.VENDOR = equ.MANUFACTUR and vm.MODEL = equ.MODEL_NUM
	join aims.COD	as etype on vm.[TYPE] = etype.code and etype.[TYPE] = 'g'
	join aims.cod	as manuf on vm.VENDOR = manuf.CODE and manuf.[TYPE] = 'm'
	left join aims.VMODEL_WARRANTY as vmw on vm.VMODEL_ID = vmw.VMODEL_ID
order by 
	 manuf.[NAME]		
	,etype.[NAME]		
	,vm.MODEL

*/

--	Check equipment for warranty info
/*

select distinct
	 fac.[NAME]			as facility
	,equ.TAG_NUMBER
	,manuf.[NAME]		as manuf
	,etype.[NAME]		as [equip type]
	,count(ew.EQU_WARRANTY_ID)	as countWarCovg
from aims.equ		as equ 
	join aims.COD	as etype on equ.[TYPE] = etype.code and etype.[TYPE] = 'g'
	join aims.cod	as manuf on equ.MANUFACTUR = manuf.CODE and manuf.[TYPE] = 'm'
	join aims.cod	as fac on equ.FACILITY = fac.CODE and fac.[TYPE] = 'y'
	left join aims.EQU_WARRANTY as ew on equ.FACILITY = ew.FACILITY and equ.TAG_NUMBER = ew.TAG_NUMBER
group by 	
	 fac.[NAME]			
	,equ.TAG_NUMBER
	,manuf.[NAME]		
	,etype.[NAME]
order by 
	 fac.[NAME]			
	,equ.TAG_NUMBER
	,manuf.[NAME]		
	,etype.[NAME]

*/


--	Inspection templates

--update aims.TYP set TEMPLATE_CODE = null 

/*

select * from aims.JOB where TEMPLATE_CODE is not null 
select * from aims.VMODEL where TEMPLATE_CODE is not null 
update aims.VMODEL set TEMPLATE_CODE = null 
select * from aims.QUESTION 
select * from aims.TEMPLATE_QUESTION
delete aims.TEMPLATE_QUESTION
delete aims.QUESTION

delete aims.template

*/

--	Oops, removed too much
/*

set identity_insert [aims].[QUESTION] ON
INSERT INTO [aims].[QUESTION]
           (QUESTION_ID
		   ,[TEMPLATE_CODE]7
           ,[QUESTION_GROUP_ID]
           ,[QUESTION]
           ,[QUESTION_TYPE]
           ,[MIN_VALUE]
           ,[MAX_VALUE]
           ,[UNIT]
           ,[NUMRANKS]
           ,[WORK_TYPE]
           ,[VERSION]
           ,[INC_PASS_FAIL]
           ,[ALLOW_CLOSE_FAIL]
           ,[TEMPLATE_TYPE]
           ,[TASK]
           ,[CREATE_DATETIME]
           ,[EXPIRE_DATETIME]
           ,[ANSWER_REQUIRED]
           ,[PASS_FAIL_REQUIRED]
           ,[YESNO_NOT_PASSFAIL]
           ,[CM_ON_FAILURE])
select 
            QUESTION_ID
		   ,TEMPLATE_CODE
           ,QUESTION_GROUP_ID
           ,QUESTION
           ,QUESTION_TYPE
           ,MIN_VALUE
           ,MAX_VALUE
           ,UNIT
           ,NUMRANKS
           ,WORK_TYPE
           ,[VERSION]
           ,INC_PASS_FAIL
           ,ALLOW_CLOSE_FAIL
           ,TEMPLATE_TYPE
           ,TASK
           ,CREATE_DATETIME
           ,EXPIRE_DATETIME
           ,ANSWER_REQUIRED
           ,PASS_FAIL_REQUIRED
           ,YESNO_NOT_PASSFAIL
           ,CM_ON_FAILURE
from OnsiteTraining2B.aims.question

*/

/*

select 
	 WO_NUMBER
	,TEMPLATE_ID
from aims.wko 
where isnull(TEMPLATE_ID,0) <> 0

*/



--	Copy address book info over from facility to facility
/*

INSERT INTO [aims].[CUSEMAIL]
           ([FACILITY]
           ,[NAME]
           ,[CONTACT]
           ,[ADDRESS]
           ,[DESCRIPTION1]
           ,[DESCRIPTION2]
           ,[EMP_NUM]
           ,[TITLE])
select 
			'REMSIT'	as [FACILITY]
           ,[NAME]
           ,CONTACT
           ,[ADDRESS]
           ,DESCRIPTION1
           ,DESCRIPTION2
           ,EMP_NUM
           ,TITLE
from aims.CUSEMAIL as cusemail
where 
	not exists	(
					select *
					from aims.cusemail as cm 
					where cm.FACILITY = 'REMSIT' 
						and 
						cm.[NAME] = cusemail.[NAME]
				)
	and cusemail.FACILITY = 'north'
 

select * from aims.CUSEMAIL
--select * from aims.cod where TYPE='y'

*/

--	Copy survey forms to other facilities
--	Did using SQL edit table tool

--	Copy forms and setup to other facilities
/*
select * from CUSFORM
select * from CUSSETUP
*/

/*

INSERT INTO [aims].[CUSFORM]
           ([FACILITY]
           ,[NAME]
           ,[SALUTATION]
           ,[RECIPIENT]
           ,[SERVER_ADDRESS]
           ,[MESSAGE_HEADER]
           ,[MESSAGE_BODY]
           ,[MESSAGE_FOOTER]
           ,[EMAIL_INTERVAL]
           ,[EMAIL_COUNTER]
           ,[HTML_FORMAT]
           ,[FONT]
           ,[SIZE]
           ,[INCLUDE_LOGO]
           ,[INCLUDE_ALL_LABOR])
select
            'REMSIT'
           ,[NAME]
           ,SALUTATION
           ,RECIPIENT
           ,SERVER_ADDRESS
           ,MESSAGE_HEADER
           ,MESSAGE_BODY
           ,MESSAGE_FOOTER
           ,EMAIL_INTERVAL
           ,EMAIL_COUNTER
           ,HTML_FORMAT
           ,FONT
           ,SIZE
           ,INCLUDE_LOGO
           ,INCLUDE_ALL_LABOR 
from aims.CUSFORM
where FACILITY = 'NORTH'

*/

/*
INSERT INTO [aims].[CUSSETUP]
           ([CUSFORM_ID]
           ,[WO_TYPE]
           ,[WO_STATUS]
           ,[CC_MAIN]
           ,[AUTO_SEND]
           ,[INTERVAL]
           ,[COUNTER]
           ,[FACILITY]
           ,[RECEIVE_INTERVAL]
           ,[COMPLETE_INTERVAL]
           ,[RECEIVE_COUNTER]
           ,[COMPLETE_COUNTER]
           ,[FACILITY_RECEIVE]
           ,[FACILITY_COMPLETE]
           ,[CC_RECEIVE]
           ,[CC_COMPLETE]
           ,[CC_NON_MAIN]
           ,[SRVC_DEPT])
select 
            CUSFORM_ID
           ,WO_TYPE
           ,WO_STATUS
           ,CC_MAIN
           ,AUTO_SEND
           ,INTERVAL
           ,[COUNTER]
           ,'REMSIT'
           ,RECEIVE_INTERVAL
           ,COMPLETE_INTERVAL
           ,RECEIVE_COUNTER
           ,COMPLETE_COUNTER
           ,FACILITY_RECEIVE
           ,FACILITY_COMPLETE
           ,CC_RECEIVE
           ,CC_COMPLETE
           ,CC_NON_MAIN
           ,SRVC_DEPT
from [aims].[CUSSETUP]
where FACILITY = 'North'
*/


--	IS Fields
/*
create table #equipTypesIsFields(
	 typeCode			varchar(50)
	,typeName			varchar(500)
	,wireless			bit
	,wired				bit
)
insert into #equipTypesIsFields
(
	 typeCode			
	,typeName			
	,wireless			
	,wired				
)
select 
	 etype.CODE
	,etype.[name]
	,0 
	,0
from aims.COD as etype
where etype.[TYPE] = 'g'
*/

--select * into aims.zzEquipTypesIsFields from #equipTypesIsFields

/*
insert into aims.zzEquipTypesIsFields
(
	 typeCode			
	,typeName			
	,wireless			
	,wired	
)
select distinct
	 etype.CODE 
	,etype.[NAME]
	,0
	,0
from aims.equ 
	join aims.cod	as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
*/


/*
select 
	 equ.FACILITY 
	,equ.TAG_NUMBER
	,etif.wired 
	,etif.wireless
	,NULL				as wiredIp
	,NULL				as wirelessIP
into aims.zzEquipIpFields
from aims.equ						as equ
	join aims.zzEquipTypesIsFields	as etif on equ.[TYPE] = etif.typeCode
	join aims.IS_EQUIP				as ise on equ.FACILITY = ise.FACILITY and equ.TAG_NUMBER = ise.TAG_NUMBER
	join aims.IS_NETWORK			as isn on ise.IS_EQUIP_ID = isn.IS_EQUIP_ID 

alter table aims.zzEquipIpFields
add ID int identity(1,1)

*/


--	Set IP Addresses
/*
declare @wiredIp		int		= 8
declare @wirelessIp		int		= 17

declare @c_facility		varchar(50)
declare @c_tagNumber	varchar(500)
declare @c_isDeviceID	int
declare @c_wired		bit
declare @c_wireless		bit

declare c_equip cursor for 
(
	select 
		 eif.facility 
		,eif.tag_number
		,eif.wired 
		,eif.wireless 
		,ise.IS_EQUIP_ID
	from aims.zzEquipIpFields	as eif
		join aims.IS_EQUIP		as ise on eif.facility = ise.FACILITY and eif.tag_number = ise.TAG_NUMBER
)
open c_equip
fetch next from c_equip into @c_facility,@c_tagNumber,@c_wired,@c_wireless,@c_isDeviceID
while @@FETCH_STATUS=0
begin 

	if @c_wired = 1
	begin 
		update aims.IS_NETWORK
		set WR_IP_V4 = '10.1.1.' + convert(varchar(3),@wiredIp)
		where IS_EQUIP_ID = @c_isDeviceID
	end 

	if @c_wireless = 1
	begin 
		update aims.IS_NETWORK
		set WF_IP_V4 = '10.1.2.' + convert(varchar(3),@wirelessIp)
		where IS_EQUIP_ID = @c_isDeviceID
	end 

	set @wiredIp	+=1
	set @wirelessIp +=1

	fetch next from c_equip into @c_facility,@c_tagNumber,@c_wired,@c_wireless,@c_isDeviceID
end 
close c_equip 
deallocate c_equip
*/

--	Tweak IS fields
/*

select 
	 fac.[NAME]						as facility
	,equ.TAG_NUMBER
	,etif.* 
	,isn.WF_IP_V4
	,isn.WF_IP_STATIC
	,isn.WR_IP_V4
	,isn.WR_IP_STATIC
from aims.equ						as equ
	join aims.zzEquipTypesIsFields	as etif on equ.[TYPE] = etif.typeCode
	join aims.IS_EQUIP				as ise on equ.FACILITY = ise.FACILITY and equ.TAG_NUMBER = ise.TAG_NUMBER
	join aims.IS_NETWORK			as isn on ise.IS_EQUIP_ID = isn.IS_EQUIP_ID 
	join aims.COD					as fac on equ.FACILITY = fac.code and fac.[TYPE] = 'y'

*/

--	Update checkboxes based on IP / DHCP
/*

update aims.IS_NETWORK
set		 WF_IP_STATIC =	case when len(wf_ip_v4) > 0 
							then 'Y' 
							else 'N' 
						 end 
		,WR_IP_STATIC = case when len(wr_ip_v4) > 0 
							then 'Y' 
							else 'N' 
						 end
		,NETWORK =	case when len(wf_ip_v4) > 0 or len(wr_ip_v4) > 0 or WF_IP_STATIC = 'N' 
						then 'Y' 
						else 'N'
					end
		,NETWORK_CONNECT =	case when len(wf_ip_v4) > 0 or len(wr_ip_v4) > 0 or WF_IP_STATIC = 'N' 
								then 'Y' 
								else 'N'
							end
		,WF_INTERNET =	case when len(wf_ip_v4) > 0 or WF_IP_STATIC = 'N' 
							then 'Y' 
							else 'N' 
						 end 
		,WR_INTERNET = case when len(wr_ip_v4) > 0 
							then 'Y' 
							else 'N' 
						end
		,WF_LAN =	case when len(wf_ip_v4) > 0 or WF_IP_STATIC = 'N' 
							then 'Y' 
							else 'N' 
						 end
		,WR_LAN = case when len(wr_ip_v4) > 0 
							then 'Y' 
							else 'N' 
						 end
from aims.IS_NETWORK as n
where 
	len(n.WF_IP_V4) > 0 
	or 
	len(n.wr_ip_v4)	> 0 
	or 
	WF_IP_STATIC = 'N'

*/


--	ECRI
/*
select 
	 manuf.[name] 
	,da.* 
from aims.dir_adr	as da
	join aims.cod	as manuf on da.code = manuf.code and manuf.[type] = 'm'
where da.[type] = 'm'
order by manuf.[name]
*/

/*
delete [aims].[DIR_ADR__ECRI_MANUF]
where dir_adr_id in (69,76,77)
*/

/*
declare @searchTerm	varchar(500) = 'Zoll Medical'
select 
	 manuf.[name]		as manuf
	,da.[DIR_ADR_ID]
from aims.cod			as manuf
	join aims.dir_adr	as da on manuf.code = da.code
where manuf.[type] = 'm'
	and 
	not exists	(	
					select * 
					from [aims].[DIR_ADR__ECRI_MANUF]
					where [DIR_ADR_ID] = da.[DIR_ADR_ID]
				)
	and left(manuf.[name],1) >= 'v'
order by manuf.[name]
select * from ecri_manuf where [name] like '%' + @searchTerm + '%' order by [name],[country] desc
*/

/*
INSERT INTO [aims].[DIR_ADR__ECRI_MANUF]
           ([DIR_ADR_ID]
           ,[ECRI_CODE])
     VALUES
           (
			    151			--<DIR_ADR_ID, numeric(5,0),>
			   ,'340083'			--<ECRI_CODE, varchar(20),>
		   )
*/


--	Equipment Type Usage on EQUIPMENT
/*

declare @ecriDevice varchar(500)	= 'mobile X-Ray Unit'
select distinct 
	 etype.code
	,etype.[name]
	,ted.*
from aims.equ
	join aims.cod						as etype on equ.[type] = etype.[code] and etype.[type] = 'g'
	left join aims.[TYP__ECRI_DEVICE]	as ted on etype.code = ted.[type]
where ted.[type] is null
	and 
	left(etype.[name],1) >= 'v'
order by etype.[name]

select 
	 code 
	,[name]
from [aims].[ecri_device]
where [name] like '%' + @ecriDevice + '%'
order by [name]

*/

/*

INSERT INTO [aims].[TYP__ECRI_DEVICE]
           ([TYPE]
           ,[ECRI_CODE])
     VALUES
           (
				''					--<TYPE, varchar(20),>
			   ,''					--<ECRI_CODE, varchar(20),>
		   )





select 
	 fac.[name]						as facility
	,equ.tag_number					as [tag #]
	,etype.[name]					as [equip type]
	,manuf.[name]					as [manuf]
	,equ.model_num					as [model #]
	,isnull(equ.equ_model_name,'')	as [model name]
from aims.equ						as equ
	left join aims.cod				as etype on equ.[type] = etype.[code] and etype.[type] = 'g'
	left join aims.cod				as manuf on equ.manufactur = manuf.code and manuf.[type] = 'm'
	left join aims.cod				as fac on equ.facility = fac.[code] and fac.[type] = 'y'
where 
	manuf.[name] like '%philips%'
order by 
	 fac.[name]						
	,equ.tag_number


select top 50
	 wo_number
	,wo_problem
from aims.wko
where facility = 'north'
order by wo_number desc

*/



--	Deletion of macros
/*

select * from aims.state_macro where group_name <> '' order by [name]
--select * from aims.rmacro where is_group = 'y' order by macro_name
--select * from aims.rdmacro order by [name]


--delete aims.state_macro where state_macro_id = 6191

delete aims.rmacro where macro_name = 'test personal log macro' and create_datetime = '2013-05-15 12:00:00.000'

update aims.rmacro
set macro_name = 'Open PMs for current month'
where macro_name = 'Brandons open PMs for current month'

update aims.state_macro
set group_name = 'Equipment'
where group_name = 'equipment'

*/



--	Expansion fields
--		Equipment
--settings
/*
select * from aims.expn
select * from aims.expd
*/


--data
/*

select 
	 fac.[name]			as facility
	,equ.tag_number		as [tag #]
	,etype.[name]		as [equip type]
	,equ.descriptn		as [descr]
	,expd.field1		as [1Alarm Priority]
	,expd.field2		as [2Default Settings]
	,expd.field3		as [3Battery Repl Due]
	,expd.field4		as [4Return to Location]
	,expd.field13		as [13Color]
	,expd.field14		as [14Logon]
	,expd.field17		as [17Current Yr Cap Budg]
	,expd.field23		as [23Software Config]
from aims.equ			as equ
	left join aims.expd as expd on equ.facility = expd.facility and equ.tag_number = expd.tag_number
	left join aims.cod	as etype on equ.[type] = etype.code and etype.[type] = 'g'
	join aims.cod		as fac on equ.facility = fac.code and fac.[type] = 'y' 
--where etype.[name] like '%central%'
where left(etype.[name],2) >= 'vh%'
order by etype.[name]

*/

/*
update aims.expd 
set field4 = 'Rad / Portable Unit Bay'
from aims.expd				as expd
	join aims.equ			as equ on expd.facility = equ.facility and expd.tag_number = equ.tag_number
	join aims.cod			as etype on equ.[type] = etype.code and etype.[type] = 'g'
where etype.[name] = 'X-Ray Unit, Mobile'
	and 
	equ.descriptn = 'Regulator, Suction, Intermittent'

update aims.expd
set field3 = NULL
where tag_number in ('428-19244')

*/





--	Rates
/*

select * from aims.rate_multi

INSERT INTO [aims].[RATE_MULTI]
           ([FACILITY]
           ,[NAME]
           ,[LABOR_TYPE]
           ,[VALUE]
           ,[DEFAULT_FIELD]
           ,[VARIABLE])
select
		    'REMSIT'			--<FACILITY, varchar(6),>
           ,[NAME]
           ,[LABOR_TYPE]
           ,[VALUE]
           ,[DEFAULT_FIELD]
           ,[VARIABLE]
from aims.rate_multi
where facility = 'North'

select * from aims.cod where type='y'

*/





--	Dashboard

/*
--Chart (Work Order Aging)
select
    case
        when Import = 'E'
            or  Import = 'N'
            then 'EasyNet WO'
        else 'Non-Easynet WO'
    end      ENWO
  , ''       blank
  , count(*) ColumnCount
from
    aims.wko
where
    WO_TYPE = 'CM'
    and REQST_DATETIME >= convert(varchar, dateadd(day, - (datepart(dw, getdate()) - 1), getdate()), 101)
                          + ' 00:00:00.000' - getdate() + getutcdate() -- = Sunday 
    and REQST_DATETIME <= convert(varchar, dateadd(day, 7 - (datepart(dw, getdate())), getdate()), 101)
                          + ' 23:59:59.000' - getdate() + getutcdate()  -- = Saturday 
group by
    case
        when Import = 'E'
            or  Import = 'N'
            then 'EasyNet WO'
        else 'Non-Easynet WO'
    end;
*/

/*
select 
	 'wko'			as code
	,''				as [name] 
	,wko.wo_number	as [value]
from aims.wko 
where wo_status not in ('CL','PS')
	and 
	wo_type	= 'IN'
*/
	--select * from aims.cod where type='t' order by name

--select * from aims.rmacro where component = 'exp'

--	Needle 1	- assigned to vendor or employee
/*

select
    count(wo_number)
from
    aims.wko
where
    WO_TYPE not in (
                       'PM', 'IN', 'IW', 'SM'
                   )
    and REQST_DATETIME between dateadd(month, datediff(month, 0, getdate()), 0)
                               and dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()) + 1, 0))
	and 
	WO_STATUS not in ('CL','PS')
	and 
	trade_emp is not null

--	Needle 2	- NOT assigned to vendor or employee
select
    count(wo_number)
from
    aims.wko
where
    WO_TYPE not in (
                       'PM', 'IN', 'IW', 'SM'
                   )
    and REQST_DATETIME between dateadd(month, datediff(month, 0, getdate()), 0)
                               and dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()) + 1, 0))
	and 
	WO_STATUS not in ('CL','PS')
	and 
	trade_emp is null

--	Odometer - total open
select
    count(wo_number) 
from
    aims.wko
where
    WO_TYPE not in (
                       'PM', 'IN', 'IW', 'SM'
                   )
    and REQST_DATETIME between dateadd(month, datediff(month, 0, getdate()), 0)
                               and dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()) + 1, 0))
	and 
	WO_STATUS not in ('CL','PS')

--	Max - total created
select
    convert(int,count(wo_number) * 1.2)
from
    aims.wko
where
    WO_TYPE not in (
                       'PM', 'IN', 'IW', 'SM'
                   )
    and REQST_DATETIME between dateadd(month, datediff(month, 0, getdate()), 0)
                               and dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()) + 1, 0))


*/


--	/* NEW QUERIES */ **********************************************************************

--	DIRECTOR:	new equipment by month
/*

select 
	 annualNewEquByMonth.insvcMonthName
		+ ' '
		+ convert(char(4),annualNewEquByMonth.insvcYear)
													as monthYear
	,''												as [name]
	,annualNewEquByMonth.countTags					as newEquip	
from 
(
select 
	 datepart(month,equ.INSVC_DATETIME)				as insvcMonth 
	,datepart(year,equ.INSVC_DATETIME)				as insvcYear
	,left(datename(month,equ.INSVC_DATETIME),3)		as insvcMonthName
	,count(TAG_NUMBER)								as countTags
from aims.equ   
	join aims.cod as fac on equ.FACILITY = fac.CODE and fac.[TYPE] = 'y'
where equ.INSVC_DATETIME between dateadd(yyyy,-1,getdate()) and  getdate()
group by 
	 datepart(month,equ.INSVC_DATETIME)				 
	,datepart(year,equ.INSVC_DATETIME)				
	,left(datename(month,equ.INSVC_DATETIME),3)	
) as annualNewEquByMonth
order by annualNewEquByMonth.insvcYear,annualNewEquByMonth.insvcMonth

*/

--	DIRECTOR:	PM Completion Trends over the year
/*

select 	 
	annualPmCplByMonth.pmMonthName
		+ ' '
		+ convert(char(4),annualPmCplByMonth.pmYear)
													as monthYear
	,''												as [name]
	,case when annualPmCplByMonth.duePms = 0 
		then 0 
		else convert(decimal(9,2),annualPmCplByMonth.closedPms)
				/ convert(decimal(9,2),annualPmCplByMonth.duePms)
	 end 											as pmComplPercent
from 
(
select 
	 datepart(month,wko.REQST_DATETIME)				as pmMonth 
	,datepart(year,wko.REQST_DATETIME)				as pmYear
	,left(datename(month,wko.REQST_DATETIME),3)		as pmMonthName
	,sum(	case when wko.WO_STATUS = 'CL' 
				then 1 
				else 0 
			end)									as closedPms
	,count(wko.wo_number)							as duePms
from aims.wko 
where WO_TYPE in ('IN','PM')
	and 
	wko.REQST_DATETIME between dateadd(yyyy,-1,getdate()) and  getdate()
group by 
	 datepart(month,wko.REQST_DATETIME)				 
	,datepart(year,wko.REQST_DATETIME)				
	,left(datename(month,wko.REQST_DATETIME),3)
) as annualPmCplByMonth
order by annualPmCplByMonth.pmYear,annualPmCplByMonth.pmMonth

*/

--	DIRECTOR:	Recall Progress
/*

select 	 
	annualPmCplByMonth.WO_PROBLEM					as recall
	,''												as [name]
	,case when annualPmCplByMonth.duePms = 0 
		then 0 
		else convert(decimal(9,2),annualPmCplByMonth.closedPms)
				/ convert(decimal(9,2),annualPmCplByMonth.duePms)
	 end 											as pmComplPercent
from 
(
select 
	 left(WO_PROBLEM,25)							as wo_problem
	,sum(	case when wko.WO_STATUS = 'CL' 
				then 1 
				else 0 
			end)									as closedPms
	,count(wko.wo_number)							as duePms
from aims.wko 
where WO_TYPE in ('HA')	
	and 
	wko.REQST_DATETIME between dateadd(yyyy,-1,getdate()) and  getdate()
group by 
	 WO_PROBLEM
) as annualPmCplByMonth
order by annualPmCplByMonth.WO_PROBLEM

*/


--	Abuse
/*

select 		
	annualSpecFails.pmMonthName
		+ ' '
		+ convert(char(4),annualSpecFails.pmYear)
													as [code] 
	,''												as [name]
	,annualSpecFails.countWOs						as [value]
from 
(
select 
	 datepart(month,wko.REQST_DATETIME)				as pmMonth 
	,datepart(year,wko.REQST_DATETIME)				as pmYear
	,left(datename(month,wko.REQST_DATETIME),3)		as pmMonthName
	,count(wko.wo_number)							as countWOs
from aims.wko 
	join aims.cod as woFail on wko.FAILURE = woFail.CODE and woFail.[TYPE] = 'f'
where 
	wko.FAILURE in ('ABY','VAN')
	and 
	wko.REQST_DATETIME between dateadd(yyyy,-1,getdate()) and  getdate()
group by 
	 datepart(month,wko.REQST_DATETIME)				
	,datepart(year,wko.REQST_DATETIME)				
	,left(datename(month,wko.REQST_DATETIME),3)
) as annualSpecFails
order by annualSpecFails.pmYear,annualSpecFails.pmMonth

*/

--	Patient Incident
/*

select 		
	annualSpecFails.pmMonthName
		+ ' '
		+ convert(char(4),annualSpecFails.pmYear)
													as [code] 
	,''												as [name]
	,annualSpecFails.countWOs						as [value]
from 
(
select 
	 datepart(month,wko.REQST_DATETIME)				as pmMonth 
	,datepart(year,wko.REQST_DATETIME)				as pmYear
	,left(datename(month,wko.REQST_DATETIME),3)		as pmMonthName
	,count(wko.wo_number)							as countWOs
from aims.wko 
	left join aims.cod as woFail on wko.FAILURE = woFail.CODE and woFail.[TYPE] = 'f'
where 
	(
		wko.FAILURE in ('PIN')
		or 
		wko.PATIENT_INJURY = 'Y'
	)
	and 
	wko.REQST_DATETIME between dateadd(yyyy,-1,getdate()) and  getdate()
group by 
	 datepart(month,wko.REQST_DATETIME)				
	,datepart(year,wko.REQST_DATETIME)				
	,left(datename(month,wko.REQST_DATETIME),3)
) as annualSpecFails
order by annualSpecFails.pmYear,annualSpecFails.pmMonth

--select * from aims.cod where TYPE='f' order by name
--select * from aims.wko where WO_NUMBER = 158976












--	Manufacturer usage
/*

select distinct supplier.[NAME] 
from aims.equ 
	join aims.cod	as supplier on equ.SUPPLIER = supplier.CODE and supplier.[TYPE] = 'm'
order by supplier.[NAME]

*/










--	PM completion
/*

select 
	 wko.facility
	,fac.[name]			as facility 
	,wko.wo_number
	,wko.REQST_DATETIME
	,wko.wo_problem
from aims.wko
	join aims.cod as fac on wko.facility = fac.code and fac.[type] = 'y'
where wo_status not in ('CL','PS')
	and 
	wo_type <> 'PM'
	--and 
	--wko.facility = 'REMSIT'
order by wko.REQST_DATETIME 

*/

*/

--	Operator Error
/*

select 		
	annualSpecFails.pmMonthName
		+ ' '
		+ convert(char(4),annualSpecFails.pmYear)
													as [code] 
	,''												as [name]
	,annualSpecFails.countWOs						as [value]
from 
(
select 
	 datepart(month,wko.REQST_DATETIME)				as pmMonth 
	,datepart(year,wko.REQST_DATETIME)				as pmYear
	,left(datename(month,wko.REQST_DATETIME),3)		as pmMonthName
	,count(wko.wo_number)							as countWOs
from aims.wko 
	join aims.cod as woFail on wko.FAILURE = woFail.CODE and woFail.[TYPE] = 'f'
where 
	wko.FAILURE in ('OER')
	and 
	wko.REQST_DATETIME between dateadd(yyyy,-1,getdate()) and  getdate()
group by 
	 datepart(month,wko.REQST_DATETIME)				
	,datepart(year,wko.REQST_DATETIME)				
	,left(datename(month,wko.REQST_DATETIME),3)
) as annualSpecFails
order by annualSpecFails.pmYear,annualSpecFails.pmMonth

--select * from aims.cod where TYPE='f' order by name
--select * from aims.wko where WO_NUMBER = 158976

*/

--	DIRECTOR:	Aging By Priority (Open / Corrective)
/*

select 		
	cmAging.ageDays									as [code] 
	,''												as [name]
	,cmAging.countWOs								as [value]
from 
(
select 
	 case 
		when datediff(hour,wko.REQST_DATETIME,getdate()) <=24
			then '< 1 day'
		when datediff(day,wko.REQST_DATETIME,getdate()) between 1 and 3
			then '1-3 days'
		when datediff(day,wko.REQST_DATETIME,getdate()) between 4 and 7
			then '4-7 days'
		when datediff(day,wko.REQST_DATETIME,getdate()) between 8 and 14 
			then '8 - 14 days'
		else '> 14 days' 
	end												as ageDays
	,case 
		when datediff(hour,wko.REQST_DATETIME,getdate()) <=24
			then 1
		when datediff(day,wko.REQST_DATETIME,getdate()) between 1 and 3
			then 2
		when datediff(day,wko.REQST_DATETIME,getdate()) between 4 and 7
			then 3
		when datediff(day,wko.REQST_DATETIME,getdate()) between 8 and 14 
			then 4
		else 5 
	end												as ageDaysSort
	,count(wko.wo_number)							as countWOs
from aims.wko 
where 
	wko.WO_STATUS not in ('CL','PS')
	and 
	wko.WO_TYPE not in ('PM','IN','IW')		
group by 
	 case 
		when datediff(hour,wko.REQST_DATETIME,getdate()) <=24
			then '< 1 day'
		when datediff(day,wko.REQST_DATETIME,getdate()) between 1 and 3
			then '1-3 days'
		when datediff(day,wko.REQST_DATETIME,getdate()) between 4 and 7
			then '4-7 days'
		when datediff(day,wko.REQST_DATETIME,getdate()) between 8 and 14 
			then '8 - 14 days'
		else '> 14 days' 
	end												
	,case 
		when datediff(hour,wko.REQST_DATETIME,getdate()) <=24
			then 1
		when datediff(day,wko.REQST_DATETIME,getdate()) between 1 and 3
			then 2
		when datediff(day,wko.REQST_DATETIME,getdate()) between 4 and 7
			then 3
		when datediff(day,wko.REQST_DATETIME,getdate()) between 8 and 14 
			then 4
		else 5 
	end	
) as cmAging
order by cmAging.ageDaysSort


*/


--	SUPERVISOR:	Recall Progress - Open by Tech
/*

select 	 
	 recallAssignments.recallAssignment				as recall
	,''												as [name]
	,recallAssignments.countWos						as pmComplPercent
from 
(
select 
	 isnull(empName.[NAME],'<NOT ASSIGNED>')		as recallAssignment
	,count(wko.wo_number)							as countWos
from aims.wko 
	left join aims.cod	as empName on wko.TRADE_EMP = empName.CODE and wko.FACILITY = empName.FACILITY and empName.[TYPE] = 'e'
where WO_TYPE in ('HA')	
	and 
	WO_STATUS not in ('CL','PS')
group by 
	 isnull(empName.[NAME],'<NOT ASSIGNED>')
) as recallAssignments
order by recallAssignments.recallAssignment

*/

--	SUPERVISOR:	Recall Aging
/*

select 	 
	 recallAging.recallAlert					as recall
	,''											as [name]
	,recallAging.ageDays						as recallAging
from 
(
select distinct
	  datediff(day,wko.REQST_DATETIME,getdate())	as ageDays
	,left(wko.WO_PROBLEM,25)						as recallAlert
from aims.wko
where WO_TYPE in ('HA')	
	and 
	WO_STATUS not in ('CL','PS')
) as recallAging
order by recallAging.recallAlert
*/


--	Alerts / Recalls
/*

select 
	 wko.FACILITY
	,wko.TAG_NUMBER
	,wko.WO_NUMBER
	,left(wko.WO_PROBLEM,25)	as [problem/alert]
from aims.WKO
where WO_TYPE in ('HA')	
	and 
	WO_STATUS not in ('CL','PS')
order by 
	 wko.FACILITY
	,left(wko.WO_PROBLEM,25)
	,wko.TAG_NUMBER

*/

--	PM Completion by assignment for current month
/*

select 
	  pmComplByAssign.pmAssignment			
	 ,''									as [name]
	 ,convert(decimal(15,2),(case when pmComplByAssign.countTotal is null 
		then 0 
		else convert(decimal(15,2),pmComplByAssign.countClosed)
				/ convert(decimal(15,2),pmComplByAssign.countTotal)
	  end))									as [numeric]
from 
(
select 
	 isnull(pmAsgn.[NAME],'<NOT ASSIGNED>')	as pmAssignment
	,sum(case when WO_STATUS in ('CL','PS') 
			then 1
			else 0
		 end)								as countClosed
	,count(wo_number)						as countTotal
from aims.wko 
	left join aims.cod		as pmAsgn on wko.TRADE_EMP = pmAsgn.CODE and wko.FACILITY = pmAsgn.FACILITY and pmAsgn.[TYPE] = 'e'
where 
	WO_TYPE = 'PM'
	and 
	wko.REQST_DATETIME between dateadd(month, datediff(month, 0, getdate()), 0)
								and
                                dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()) + 1, 0))
group by isnull(pmAsgn.[NAME],'<NOT ASSIGNED>')
) as pmComplByAssign
order by pmComplByAssign.pmAssignment

*/

--	Open CM Breakdown by Priority
/*

select 
	 isnull(prty.[NAME],'<NO SELECTION>')	as [priority]
	,''										as [name] 
	,count(wko.wo_number)					as [numeric]
from aims.wko 
	left join aims.COD	as prty on wko.[PRIORITY] = prty.CODE and prty.[TYPE] = 'q'
where 
	WO_TYPE not in ('PM','IN','IW')	
	and 
	WO_STATUS not in ('CL','PS')
group by isnull(prty.[NAME],'<NO SELECTION>')
order by isnull(prty.[NAME],'<NO SELECTION>')

*/

--	TECHNICIAN:	Open PM by Tech
/*

select 
	 isnull(empName.[NAME],'<NOT ASSIGNED>')		as [code] 
	,''												as [name] 
	,count(wko.WO_NUMBER)							as [value]
from aims.wko 
	left join aims.cod	as empName on wko.TRADE_EMP = empName.CODE and wko.FACILITY = empName.FACILITY and empName.[TYPE] = 'e'
where 
	WO_TYPE = 'PM'
	and 
	wko.REQST_DATETIME between dateadd(month, datediff(month, 0, getdate()), 0)
								and
                                dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()) + 1, 0))
group by isnull(empName.[NAME],'<NOT ASSIGNED>')	
order by isnull(empName.[NAME],'<NOT ASSIGNED>')

*/

--	TECHNICIAN:	Open PMs by Risk
/*
--	Needle 1 - High Risk
select 									
	count(wko.WO_NUMBER)	as [value]
from aims.wko 
	left join aims.cod	as empName on wko.TRADE_EMP = empName.CODE and wko.FACILITY = empName.FACILITY and empName.[TYPE] = 'e'
	left join aims.EQU	as equ on wko.FACILITY = equ.FACILITY and wko.TAG_NUMBER = equ.TAG_NUMBER
	left join aims.ERSK	as ersk on equ.FACILITY = ersk.FACILITY and equ.TAG_NUMBER = ersk.TAG_NUMBER
where 
	WO_TYPE = 'PM'
	and 
	wko.REQST_DATETIME between dateadd(month, datediff(month, 0, getdate()), 0)
								and
                                dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()) + 1, 0))
	and 
	ersk.RISK_TYPE = 'C'

--	Needle 2 = Non-High Risk
select 									
	count(wko.WO_NUMBER)	as [value]
from aims.wko 
	left join aims.cod	as empName on wko.TRADE_EMP = empName.CODE and wko.FACILITY = empName.FACILITY and empName.[TYPE] = 'e'
	left join aims.EQU	as equ on wko.FACILITY = equ.FACILITY and wko.TAG_NUMBER = equ.TAG_NUMBER
	left join aims.ERSK	as ersk on equ.FACILITY = ersk.FACILITY and equ.TAG_NUMBER = ersk.TAG_NUMBER
where 
	WO_TYPE = 'PM'
	and 
	wko.REQST_DATETIME between dateadd(month, datediff(month, 0, getdate()), 0)
								and
                                dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()) + 1, 0))
	and 
	ersk.RISK_TYPE = 'P'

--	Odometer - All
select 									
	count(wko.WO_NUMBER)	as [value]
from aims.wko 
	left join aims.cod	as empName on wko.TRADE_EMP = empName.CODE and wko.FACILITY = empName.FACILITY and empName.[TYPE] = 'e'
	left join aims.EQU	as equ on wko.FACILITY = equ.FACILITY and wko.TAG_NUMBER = equ.TAG_NUMBER
	left join aims.ERSK	as ersk on equ.FACILITY = ersk.FACILITY and equ.TAG_NUMBER = ersk.TAG_NUMBER
where 
	WO_TYPE = 'PM'
	and 
	wko.REQST_DATETIME between dateadd(month, datediff(month, 0, getdate()), 0)
								and
                                dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()) + 1, 0))
*/

  

--	Manufacturer usage
/*

select distinct supplier.[NAME] 
from aims.equ 
	join aims.cod	as supplier on equ.SUPPLIER = supplier.CODE and supplier.[TYPE] = 'm'
order by supplier.[NAME]

*/


--	PM Completion by Risk for current month
/*

select 
	 openPmByRisk.riskClass
	,''							as [name] 
	,case when openPmByRisk.countTotal = 0 
		then 0 
		else convert(decimal(15,2),convert(decimal(15,2),openPmByRisk.countClosed)
				/ 
				convert(decimal(15,2),openPmByRisk.countTotal))
	 end						as [numeric]
from 
(
select  
	 case 
		when ersk.RISK_TYPE = 'C'
			then 'High Risk' 
		when ersk.RISK_TYPE = 'P'
			then 'Non-High Risk'
		else 'Life Safety' 
	 end									as riskClass
	,sum(case when WO_STATUS in ('CL','PS') 
			then 1
			else 0
		 end)								as countClosed
	,count(wko.wo_number)					as countTotal
from aims.WKO
	left join aims.equ on wko.FACILITY = equ.FACILITY and wko.TAG_NUMBER = equ.TAG_NUMBER
	left join aims.ERSK as ersk on equ.facility = ersk.facility and equ.TAG_NUMBER = ersk.TAG_NUMBER
where 
	WO_TYPE = 'PM'
	and 
	wko.REQST_DATETIME between dateadd(month, datediff(month, 0, getdate()), 0)
								and
                                dateadd(s, -1, dateadd(mm, datediff(m, 0, getdate()) + 1, 0))
group by 
	 case 
		when ersk.RISK_TYPE = 'C'
			then 'High Risk' 
		when ersk.RISK_TYPE = 'P'
			then 'Non-High Risk'
		else 'Life Safety' 
	 end									
) as openPmByRisk

*/







--	PM completion
/*

select 
	 --wko.facility
	fac.[name]			as facility 
	,wko.wo_number		as [WO #]
	,etype.[NAME]		as [equip type]
	,wko.REQST_DATETIME
	--,wko.wo_problem
from aims.wko
	join aims.cod		as fac on wko.facility = fac.code and fac.[type] = 'y'
	left join aims.cod	as etype on wko.[TYPE] = etype.[CODE] and etype.[TYPE] = 'g'
where wo_status not in ('CL','PS')
	and 
	wo_type = 'PM'
	and 
	wko.REQST_DATETIME between '10/1/2021' and '10/30/2021'
order by 
	fac.[name]			
	,wko.wo_number

select * from aims.cod where TYPE='r' order by name

*/

/*
select * from aims.prt order by part_desc
*/







/*
select * from aims.prt order by part_desc
*/



--	WO Expansion fields
/*

select 
	 facName.[NAME] as facility
	,wko.TAG_NUMBER
	,wko.WO_NUMBER
	,wko.WO_PROBLEM
	,wexpd.FIELD14	as [EQ Cleaned] 
	,wexpd.FIELD17	as [Mgmt Reviewed]
	,wko.[type]
from aims.wko 
	left join aims.WEXPD on wko.FACILITY = wexpd.FACILITY and wko.WO_NUMBER = wexpd.WO_NUMBER
	join aims.COD	as facName on wko.facility = facName.CODE and facName.[TYPE] = 'y'
where REQST_DATETIME > '9/1/2021'
order by wko.[type]

*/

/*

update aims.WEXPD
set FIELD17 = 'Y'
from aims.wko 
	left join aims.WEXPD on wko.FACILITY = wexpd.FACILITY and wko.WO_NUMBER = wexpd.WO_NUMBER
	join aims.COD	as facName on wko.facility = facName.CODE and facName.[TYPE] = 'y'
where REQST_DATETIME > '9/1/2021'
	and 
	wko.[type] <> 'AIRHAND'
	and 
	wko.WO_STATUS in ('CL','PS')

*/



/*

declare @c_facility		varchar(50)
		,@c_woNumber	varchar(500)

declare c_newWOs cursor for 
(
	select 
		 wko.facility 
		,wko.wo_number 
	from aims.wko 
		left join aims.WEXPD on wko.FACILITY = wexpd.FACILITY and wko.WO_NUMBER = wexpd.WO_NUMBER
		join aims.COD	as facName on wko.facility = facName.CODE and facName.[TYPE] = 'y'
	where REQST_DATETIME > '9/1/2021'
) 
open c_newWOs 
fetch next from c_newWOs into @c_facility,@c_woNumber
while @@FETCH_STATUS=0
begin 

	if not exists(select * from aims.WEXPD where facility = @c_facility and WO_NUMBER = @c_woNumber)
	begin 


		INSERT INTO [aims].[WEXPD]
           (
			   [WO_NUMBER]
			   ,[FACILITY]
			)
		VALUES
           (
			   @c_woNumber		-- <WO_NUMBER, int,>
			   ,@c_facility		--<FACILITY, varchar(6),>
           )

	end 


	fetch next from c_newWOs into @c_facility,@c_woNumber
end 
close c_newWOs 
deallocate c_newWOs

*/


--	WO Expansion fields
/*

select * from aims.WEXPD


update aims.wexpd 
set field14 = 'Yes'
where FACILITY = 'NORTH' and WO_NUMBER = '159044'


update aims.wexpd 
set	FIELD17 = 'N'
	,FIELD18 = 'N'
	,FIELD19 = 'N'
	,FIELD20 = 'N'
	,FIELD21 = 'N'
	,FIELD22 = 'N'
where FIELD17 = 'N'

*/


--	Purchase Order / contract
/*
select 
	 po.PO_NUM
	,count(li.LINE_ITEM_ID)	as countLineItems
from aims.PO
	left join aims.LINE_ITEM as li on po.PO_ID = li.PO_ID
group by po.PO_NUM
*/

--/*

--	PO Analysis - what is in there now?
/*

select 
	 fac.[NAME]					as facility
	,po.PO_NUM
	,po.PO_STATUS
	,convert(varchar(50),po.PO_DATETIME,101)	as poDate
	,pc.[DESCRIPTION]			as [PO Status Name]
	--,cnt.CONTROL_ID
	--,li.*
from aims.PO
	--left join aims.LINE_ITEM	as li on po.PO_ID = li.PO_ID
	--left join aims.cnt			as cnt on po.PO_NUM = cnt.PO_NUMBER
	left join aims.PUR_COD		as pc on po.PO_STATUS = pc.code and pc.[TYPE] = 'OS'
	join aims.cod				as fac on po.FACILITY = fac.CODE and fac.[TYPE] = 'y'
where po.PO_STATUS not in ('C','IN')
order by fac.[NAME],PO_NUM

select * from aims.request

*/

--	Cleanup exissting PO / Req
/*

update aims.po 
set PO_STATUS = 'C'
from aims.PO
	left join aims.PUR_COD		as pc on po.PO_STATUS = pc.code and pc.[TYPE] = 'OS'
	join aims.cod				as fac on po.FACILITY = fac.CODE and fac.[TYPE] = 'y'
where po.PO_STATUS not in ('C','IN')

*/







 




--	Fix Request / PO #'s to use sequential
/*

declare @nextPoNumber	varchar(50) = '1921032'
		,@c_poId		int	

declare c_po cursor for
(
select PO_ID
from aims.PO
where isnumeric(PO_NUM) = 0
	or 
	len(po_num) >= 10
)
open c_po
fetch next from c_po into @c_poId 
while @@FETCH_STATUS=0
begin 

	update aims.po 
	set PO_NUM = @nextPoNumber
	where PO_ID = @c_poId

	set @nextPoNumber +=1

	fetch next from c_po into @c_poId 
end
close c_po
deallocate c_po

select 
	max(request_num)
from aims.REQUEST
where isnumeric(REQUEST_NUM) = 0

update aims.request
set request_num = left(request_num,9)
where len(request_num) >= 10

select * from aims.cod where TYPE='y'

select max(request_num) as maxReqNum from aims.REQUEST where facility = 'south'
select max(po_num) as MaxPoNum from aims.po where FACILITY = 'south'



select * 
from aims.PRT
where FACILITY = 'remsit'

select * from aims.cod where TYPE='y'

select * from aims.PUR_COD where FACILITY = 'south' and type = 'et' order by [DESCRIPTION]

select * from aims.prt where FACILITY = 'south'

--*/




--	Equipment count by type
/*

select  
	 equ.DESCRIPTN
	,equ.MODEL_NUM
	,manuf.[NAME]		as manuf
	,count(tag_number)	as cntTags
from aims.EQU 
	join aims.cod	as manuf on equ.MANUFACTUR = manuf.CODE and manuf.[TYPE] = 'm'
	join aims.cod	as fac on equ.FACILITY = fac.CODE and fac.[TYPE] = 'y'
where equ.FACILITY = 'north'
group by 
	 equ.DESCRIPTN
	,equ.MODEL_NUM
	,manuf.[NAME]
order by 
	 equ.DESCRIPTN
	,equ.MODEL_NUM

*/

--	Cleared contracts, they were junk
/*

select 
	 cnt.CONTROL_ID
	,convert(varchar(50),cnt.BEGINNING_DATETIME,101)	as [start]
	,convert(varchar(50),cnt.ENDING_DATETIME,101)		as [end]
	,fac.[NAME]			as facility
	,equ.TAG_NUMBER 
	,etype.[NAME]		as [equ type]
from aims.CNT			as cnt
	join aims.EQU_CNT	as ecnt on cnt.CONTROL_ID = ecnt.CONTROL_ID
	join aims.equ		as equ on ecnt.FACILITY = equ.FACILITY and ecnt.TAG_NUMBER = equ.TAG_NUMBER
	left join aims.COD	as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	join aims.COD		as fac on equ.FACILITY = fac.CODE and fac.[TYPE] = 'y'
order by cnt.CONTROL_ID,etype.[NAME]

select * from aims.wcm where WORK_TYPE = 'c'
select * from aims.WCT where WORK_TYPE = 'c'

delete from aims.EQU_CNT
delete from aims.climits
delete from aims.CNT_PAYMENT
delete from aims.CRATE
delete from aims.CNT

*/

--	Cleanup equipment logs
/*

;with cte_minNotesDate(facility,tag_number,minNotesDate)
as(
		select 
			 n.FACILITY 
			,n.TAG_NUMBER
			,convert(varchar(50),min(n.NOTE_DATETIME),101)
		from aims.NOTES as n
		group by n.FACILITY,n.TAG_NUMBER
)
select 
	 fac.[NAME]										as facility
	,equ.TAG_NUMBER
	,etype.[NAME]									as [equip type]
	,notes.NOTE_DATETIME
	,notes.NOTES
	,mnd.minNotesDate
	,cvg.[DESCRIPTION]								as [warranty]
	,convert(varchar(50),ew.EXPIRE_DATETIME,101)	as [war exp]
	,convert(varchar(50),equ.INSVC_DATETIME,101)	as [insv date]
from aims.equ 
	left join aims.NOTES on equ.FACILITY = notes.FACILITY and equ.TAG_NUMBER = notes.TAG_NUMBER
	left join cte_minNotesDate		as mnd on equ.FACILITY = mnd.facility and equ.TAG_NUMBER = mnd.tag_number
	join aims.COD				as fac on equ.FACILITY = fac.CODE and fac.[TYPE] = 'y'
	left join aims.COD				as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	left join aims.EQU_WARRANTY as ew on equ.FACILITY = ew.FACILITY and equ.TAG_NUMBER = ew.TAG_NUMBER
		left join aims.COVERAGE		as cvg on ew.COVERAGE_ID = cvg.COVERAGE_ID
where 
	notes.notes like 'Description%'
	or 
	notes.notes like 'Equipment Type%'
order by etype.[NAME],equ.tag_number,notes.NOTE_DATETIME desc

*/


--	Put equipment on contract


;with cte_minNotesDate(facility,tag_number,minNotesDate)
as(
		select 
			 n.FACILITY 
			,n.TAG_NUMBER
			,convert(varchar(50),min(n.NOTE_DATETIME),101)
		from aims.NOTES as n
		group by n.FACILITY,n.TAG_NUMBER
)
select 
	 fac.[NAME]										as facility
	,equ.TAG_NUMBER
	,etype.[NAME]									as [equip type]
	,equ.[DESCRIPTN]								as [equip descr]
	,equ.MODEL_NUM
	,mnd.minNotesDate
	,cvg.[DESCRIPTION]								as [warranty]
	,convert(varchar(50),ew.EXPIRE_DATETIME,101)	as [war exp]
	,convert(varchar(50),equ.INSVC_DATETIME,101)	as [insv date]
	,estatus.[NAME]									as [status]
	,manufName.[NAME]								as [manuf]
from aims.equ 
	left join cte_minNotesDate	as mnd on equ.FACILITY = mnd.facility and equ.TAG_NUMBER = mnd.tag_number
	join aims.COD				as fac on equ.FACILITY = fac.CODE and fac.[TYPE] = 'y'
	left join aims.COD			as etype on equ.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
	left join aims.EQU_WARRANTY as ew on equ.FACILITY = ew.FACILITY and equ.TAG_NUMBER = ew.TAG_NUMBER
		left join aims.COVERAGE	as cvg on ew.COVERAGE_ID = cvg.COVERAGE_ID
	join aims.cod				as estatus on equ.EQU_STATUS = estatus.CODE and estatus.[TYPE] = 's'
	join aims.COD				as manufName on equ.MANUFACTUR = manufName.code and manufName.[TYPE] = 'm'
order by etype.[NAME],equ.tag_number

/*

begin tran 
update aims.notes 
set notes = replace(convert(varchar(max),notes),'Radiographic','Anesthesia Units')
where facility = 'north' 
	and 
	TAG_NUMBER in ('7616','7668')
	and 
	convert(varchar(max),NOTES) like '%Radiographic%'

update aims.wko 
set WO_PROBLEM = replace(wo_problem,'Radiographic','Anesthesia Units')
from aims.wko
where facility = 'north' 
	and 
	TAG_NUMBER in ('7616','7668')
	and 
	convert(varchar(max),WO_PROBLEM) like '%Radiographic%'


	commit tran

*/


--	Remove log notes where the type or description changed drastically
/*

begin tran
delete aims.NOTES
where facility = 'north' and TAG_NUMBER in ('24429','24433')
	and 
	convert(varchar(max),NOTES) = 'Description has been changed from Anesthesia Unit to Anesthesia Machine.  Description changed by AIMS from the Equipment Control.'

	
	commit tran

*/

--	Unique make/model actually used
/*

select distinct
	 manufName.[NAME]
	,vm.MODEL
	,etype.[NAME]
	,equ.DESCRIPTN
from aims.VMODEL	as vm
	join aims.EQU	as equ on vm.VENDOR = equ.MANUFACTUR and vm.[TYPE] = equ.[TYPE] and vm.MODEL = equ.MODEL_NUM
	join aims.COD	as manufName on vm.VENDOR = manufName.CODE and manufName.[TYPE] = 'm'
	join aims.COD	as etype on vm.[TYPE] = etype.CODE and etype.[TYPE] = 'g'
where equ.EQU_STATUS = 'iu'	
order by 
	 manufName.[NAME]
	,vm.MODEL

*/