CREATE PROC [cmo].[sp_CMO_FLAT_GLOBAL_INDICATOR_CAPACITY_APO]
AS
BEGIN
	-------------------------- ferm ------------------------------------------------

	drop table if exists #temp3
	select 	cast(cast(t.year_month as varchar) + '01' as date) as year_month,
		ferm_plant as ferm_plant_sigla,
		t.bulk_code,
		reg.acronyms as delivery_region,
		0 as inv_perc,
		1 as sell_perc,
		0 as inv_m3,
		t.loading_m3 as sell_m3,
		vmat.is_granulation
	into #temp3
	from cmo.CMO_APO_PRODUCTION t
	INNER JOIN cmo.CMO_REGION reg ON reg.id = t.region_id
	INNER JOIN cmo.vw_unique_trusted_material vmat ON vmat.bulk_code = t.bulk_code
	where vmat.is_granulation = 0  
	

	drop table if exists #ferm_m3
	select
		'APO' as scenario,
		GETDATE() as creation_date,
		ferm.year_month as date,
		ferm_plant_sigla as plant,
		bulk_code,
		delivery_region as region,
		sum(sell_m3) as capacity_sell,
		sum(inv_m3) as capacity_inv,
		is_granulation
	into #ferm_m3
	from #temp3 ferm
	group by
		year_month,
		ferm_plant_sigla,
		bulk_code,
		delivery_region,
		is_granulation
	order by ferm_plant_sigla, year_month 

	
	-------------------------- gran ----------------------------------------------

	drop table if exists #temp4
	select cast(cast(t.year_month as varchar) + '01' as date) as year_month,
		t.finish_site as finish_site_plant_sigla,
		t.bulk_code,
		reg.acronyms as region,
		0 inv_perc,
		1 as sell_perc,
		0 as inv_mvch,
		(rbc_loading_mvch + vector_loading_mvch) as sell_mvch,
		vmat.is_granulation
	into #temp4
	from cmo.CMO_APO_PRODUCTION t
	LEFT JOIN cmo.CMO_REGION reg ON reg.id = t.region_id
	INNER JOIN cmo.vw_unique_trusted_material vmat ON vmat.bulk_code = t.bulk_code
	where (rbc_loading_mvch + vector_loading_mvch) >0 AND vmat.is_granulation = 1

	drop table if exists #gran_mvch
	select
		'APO' as scenario,
		GETDATE() as creation_date,
		year_month,
		finish_site_plant_sigla as plant,
		bulk_code,
		region,
		sum(sell_mvch) as capacity_sell,
		sum(inv_mvch) as capacity_inv,
		is_granulation
	into #gran_mvch
	from #temp4 gran
	group by
		year_month,
		finish_site_plant_sigla,
		bulk_code,
		region,
		is_granulation
	order by finish_site_plant_sigla, year_month 

	----------------------------------------------------------------------------------------------
	drop table if exists #final
	select *  into #final from #ferm_m3
	WHERE [date] between DATEADD(MONTH, 2, GETDATE())  AND DATEADD(MONTH, 13, GETDATE())
	union
	select * from #gran_mvch
	WHERE year_month between DATEADD(MONTH, 2, GETDATE())  AND DATEADD(MONTH, 13, GETDATE())

	BEGIN TRAN
	
	DELETE [cmo].[FLAT_CAPACITY] WHERE scenario_name = 'APO';
	INSERT INTO [cmo].[FLAT_CAPACITY]
	SELECT [bulk],
	bulk_code,
	loading_year_month,
	scenario_name,
	loading_capacity,
	is_granulation,
	producing_site,
	CASE 
			WHEN PPC_bulk = 'High ACR - High $' AND is_granulation = 0  THEN 'High VP$/M3 - High $'
			WHEN PPC_bulk = 'High ACR - High $' AND is_granulation = 1 THEN 'High VP$/mVCH - High $'
			WHEN PPC_bulk = 'High ACR - Low $' AND is_granulation = 0 THEN 'High VP$/M3 - Low $'
			WHEN PPC_bulk = 'High ACR - Low $' AND is_granulation = 1 THEN 'High VP$/mVCH - Low $'
			WHEN PPC_bulk = 'Low ACR - High $' AND is_granulation = 0 THEN 'Low VP$/M3 - High $'
			WHEN PPC_bulk = 'Low ACR - High $' AND is_granulation = 1 THEN 'Low VP$/mVCH - High $'
			WHEN PPC_bulk = 'Low ACR - Low $' AND is_granulation = 0 THEN 'Low VP$/M3 - Low $'
			WHEN PPC_bulk = 'Low ACR - Low $' AND is_granulation = 1 THEN 'Low VP$/mVCH - Low $'
			ELSE 'Can not be calculated'
		END AS PPC_bulk,
	scenario_created_at,
	region,
	[scenario_updated_at], 
	plant_name	
	FROM (SELECT tm.[bulk],
	fn.bulk_code,
	fn.[date] as loading_year_month,
	fn.scenario as scenario_name,
	fn.capacity_sell as loading_capacity,
	fn.is_granulation,
	fn.plant as producing_site,
	CASE 
		WHEN fn.is_granulation = 0 THEN class.PPC_bulk
		ELSE class.PPC_mvch_bulk
	END AS PPC_bulk,
	fn.creation_date as scenario_created_at,
	fn.region,
	GETDATE() as [scenario_updated_at], 
	pv.[name] as plant_name FROM #final fn
	LEFT JOIN cmo.vw_unique_trusted_material tm ON tm.bulk_code = fn.bulk_code
	LEFT JOIN cmo.vw_vp_classification class ON class.bulk_code = fn.bulk_code AND class.region = fn.region AND class.business_unit = tm.business_unit
	LEFT JOIN (SELECT DISTINCT CASE 
			WHEN [name] = 'Genencor Intl Wiscon' THEN 'Beloit'
			WHEN [name] = 'APO DuPont NHIB Grindste ' THEN 'Grindsted'
			WHEN [name] = 'DuPont NHIB Grindste' THEN 'Grindsted'
			WHEN [name] = 'Finnfeeds OY Vaasan ' THEN 'Vaasa'
			ELSE [name]
		END as [name],
		plant_sigla 
		FROM cmo.CMO_PLANT_VARCHAR) pv ON pv.plant_sigla = fn.plant
	) X

	DELETE [cmo].[FLAT_CAPACITY_INVENTORY] WHERE scenario_name = 'APO';
	INSERT INTO [cmo].[FLAT_CAPACITY_INVENTORY]
	SELECT tm.[bulk],
	fn.bulk_code,
	fn.[date] as loading_year_month,
	fn.scenario as scenario_name,
	fn.creation_date as scenario_created_at,
	SUM(fn.capacity_sell) as loading_capacity,
	SUM(fn.capacity_inv) as inventory_build,
	fn.is_granulation,
	fn.plant as producing_site,
	GETDATE() as [scenario_updated_at],
	pv.[name] as plant_name FROM #final fn
	LEFT JOIN cmo.vw_unique_trusted_material tm ON tm.bulk_code = fn.bulk_code
	LEFT JOIN (SELECT DISTINCT CASE 
			WHEN [name] = 'Genencor Intl Wiscon' THEN 'Beloit'
			WHEN [name] = 'APO DuPont NHIB Grindste ' THEN 'Grindsted'
			WHEN [name] = 'DuPont NHIB Grindste' THEN 'Grindsted'
			WHEN [name] = 'Finnfeeds OY Vaasan ' THEN 'Vaasa'
			ELSE [name]
		END as [name],
		plant_sigla 
		FROM cmo.CMO_PLANT_VARCHAR) pv ON pv.plant_sigla = fn.plant
	GROUP BY tm.[bulk],
	fn.bulk_code,
	fn.[date],
	fn.scenario ,
	fn.creation_date,
	fn.is_granulation,
	fn.plant,
	pv.[name]



	DELETE [cmo].[FLAT_GLOBAL_INDICATOR_CAPACITY] WHERE scenario = 'APO';
	INSERT INTO [cmo].[FLAT_GLOBAL_INDICATOR_CAPACITY]
	SELECT scenario,
		scenario_created_at,
		[date], --as loading_year_month,
		CASE 
			WHEN VP$ = 'High ACR - High $' AND is_granulation = 0  THEN 'High VP$/M3 - High $'
			WHEN VP$ = 'High ACR - High $' AND is_granulation = 1 THEN 'High VP$/mVCH - High$'
			WHEN VP$ = 'High ACR - Low $' AND is_granulation = 0 THEN 'High VP$/M3 - Low $'
			WHEN VP$ = 'High ACR - Low $' AND is_granulation = 1 THEN 'High VP$/mVCH - Low $'
			WHEN VP$ = 'Low ACR - High $' AND is_granulation = 0 THEN 'Low VP$/M3 - High $'
			WHEN VP$ = 'Low ACR - High $' AND is_granulation = 1 THEN 'Low VP$/mVCH - High $'
			WHEN VP$ = 'Low ACR - Low $' AND is_granulation = 0 THEN 'Low VP$/M3 - Low $'
			WHEN VP$ = 'Low ACR - Low $' AND is_granulation = 1 THEN 'Low VP$/mVCH - Low $'
			ELSE 'Can not be calculated'
		END AS VP$,
		is_granulation,
		business_unit,
		plant_sigla,
		plant_name,
		SUM(loading) as loading,
		[scenario_updated_at]
	FROM (SELECT fn.scenario,
		fn.creation_date as scenario_created_at,
		fn.[date], --as loading_year_month,
		CASE
			WHEN fn.is_granulation = 0 THEN isnull(vpc.PPC_bulk,'Can not be calculated')
			ELSE (isnull(vpc.PPC_mvch_bulk,'Can not be calculated'))
		END AS VP$,
		fn.is_granulation,
		vpc.business_unit,
		fn.bulk_code,
		fn.plant as plant_sigla,
		pv.[name] as plant_name,
		fn.capacity_sell as loading,
		GETDATE() as [scenario_updated_at] 
		FROM #final fn
		LEFT JOIN (SELECT DISTINCT CASE 
				WHEN [name] = 'Genencor Intl Wiscon' THEN 'Beloit'
				WHEN [name] = 'APO DuPont NHIB Grindste ' THEN 'Grindsted'
				WHEN [name] = 'DuPont NHIB Grindste' THEN 'Grindsted'
				WHEN [name] = 'Finnfeeds OY Vaasan ' THEN 'Vaasa'
				ELSE [name]
			END as [name],
			plant_sigla 
			FROM cmo.CMO_PLANT_VARCHAR) pv ON pv.plant_sigla = fn.plant
		LEFT JOIN cmo.vw_vp_classification vpc ON vpc.bulk_code = fn.bulk_code AND vpc.region = fn.region --AND tm.business_unit = vpc.business_unit
		WHERE EXISTS (SELECT DISTINCT bulk_code, region FROM cmo.vw_TRUSTED_MAKE_SITES tms where tms.bulk_code = fn.bulk_code AND tms.region = fn.region) 
		) X
	GROUP BY scenario,
		scenario_created_at,
		[date],
		is_granulation,
		business_unit,
		plant_sigla,
		plant_name,
		VP$,
		[scenario_updated_at]
		
	COMMIT TRAN
END
GO