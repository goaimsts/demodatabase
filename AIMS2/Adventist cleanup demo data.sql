



--	https://onsitetraining2.aimsasp.net/
--	dbserver02\sql2017.OnsiteTraining2

--	Locations
/*
select * 
from aims.loc as loc
	left join aims.cod as locName on loc.CODE = locName.CODE and (loc.FACILITY = locName.FACILITY or locName.FACILITY = 'MAIN') and locName.[TYPE] = 'o'

--	These are totally generic
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