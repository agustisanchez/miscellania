select
	row_to_json( T )
from
	(
	select
		syn_synthesis_id as "synthesisId",
		syn_title as "synthesisTitle",
		(
		select
			array_to_json( array_agg( row_to_json( schemes )))
		from
			(
			select
				sch_scheme_id as "schemeId",
				sch_filename as "schemeFilename",
				sch_sibling_order as "schemeSiblingOrder",
				sch_text as "schemeText"
			from
				prous_approved.syn_schemes
			where
				sch_synthesis_id = syn_synthesis_id ) schemes ) as "synthesisScheme",
		(
		select
			array_to_json( array_agg( row_to_json( endProducts )))
		from
			(
			select
				spr_entry_number as "drugId",
				ppn_name as "drugNameMain",
				array_to_json( array_agg(pcn_chemical_name)) as "drugNameChemical",
				str_formula as "drugFormula",
				str_molweight as "drugWeight"
			from
				prous_approved.syn_synthesis_end_products
			left outer join prous_approved.pro_product_names on
				ppn_entry_number = spr_entry_number
				and ppn_main_mfline = 'Y'
			left outer join prous_approved.pro_chem_names on
				pcn_entry_number = spr_entry_number
			left outer join prous_approved.structures_symyx on
				str_entry_number = spr_entry_number
			where
				spr_synthesis_id = syn_synthesis_id
			group by
				spr_entry_number,
				ppn_name,
				str_formula,
				str_molweight ) endProducts ) as "synthesisEndProduct"
	from
		prous_approved.syn_synthesis
	where
		syn_status_id = 3 ) as T
