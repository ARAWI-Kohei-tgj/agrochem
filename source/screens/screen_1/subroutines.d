module screens.screen_1.subroutines;

import dpq2: Connection;
import dlangui;
import utils: SpraySummary;

/**
 *
 ****/ 
void updateSummaryTree(Connection conn, ref TreeWidget tree,
		in ushort selectedIdCrop, ref SpraySummary[] sprayInfoSummary){
	import std.conv: dtext;
	import utils: integerToHexStr;

	sprayInfoSummary= getSpraySummary(conn, selectedIdCrop);
	tree.clearAllItems;
	if(sprayInfoSummary.length > 0){
		foreach(theSpray; sprayInfoSummary){
			tree.items.newChild(integerToHexStr(theSpray.sprayId), theSpray.dateSpray.toISOExtString.dtext);
		}

		// select the last item
		tree.selectItem(tree.items.child(tree.items.childCount-1).id);
	}
	else{}
} 

/***
 *
 ****/
SpraySummary[] getSpraySummary(Connection conn, in ushort cropId) @system{
	//import std.algorithm: each;
	import std.datetime: Date;
	import dpq2;
	import dpq2.conv.time: binaryValueAs;
	import postgresql: DataBaseAccess;

	@(DataBaseAccess.readonly) QueryParams cmd;
	typeof(return) result;

	with(cmd){
		sqlCommand= `SELECT id_spray, spray_date, spray_type, amount_num, amount_unit
	FROM spray_summary
	WHERE crop_id = $1::SMALLINT;`;
		args.length= 1;
		args[0]= toValue(cast(short)cropId);
	}

	auto ans= conn.execParams(cmd);

	foreach(row; ans.rangify){
		result ~= SpraySummary(cast(ushort)(row["id_spray"].as!int),
			row["spray_date"].binaryValueAs!Date,
			row["spray_type"].as!string,
			row["amount_num"].as!double,
			row["amount_unit"].as!string);
	}
	/+
	TODO: use below instead of avobe
	ans.rangify.each!(row => result ~= SpraySummary(
			cast(ushort)(row["id_spray"].as!int),
			row["spray_date"].binaryValueAs!Date,
			row["spray_type"].as!string,
			row["amount_num"].as!double,
			row["amount_unit"].as!string));
	+/
	return result;
}

/**
 * 散布内容の詳細を取得しStringGridWidgetへ表示
 *
 * DB_Access:
 *  Table 'spray_detail' as readonly
 *
 ****/
int getDetails(Connection conn, StringGridWidget grid, TreeItem branch) @system{
	import std.conv: dtext, to;
	import dpq2;
	import postgresql: DataBaseAccess;
	import utils: hexStrToUshort;
	import screens.screen_1.process: listOfPesticides, selectedIdCrop;


	enum TOTAL_COLUMN_DETAILS= 5u;
	typeof(return) result;
	if(branch){
		@(DataBaseAccess.readonly) QueryParams cmdDetail;
		@(DataBaseAccess.readonly) QueryParams cmdTotalUse;
		@(DataBaseAccess.readonly) QueryParams cmdSprayDate;

		result= hexStrToUshort(branch.id);	// spray_id
		/**
		 * buffer clean-up
		 */
		foreach(int idxRow; 0u..grid.rows){
			foreach(int idxCol; 0u..TOTAL_COLUMN_DETAILS) grid.setCellText(idxCol, idxRow, ""d);
		}

		with(cmdDetail){
			sqlCommand= `SELECT chem_code,
					dilution_num,
					dilution_unit,
					purpose
				FROM spray_detail
				WHERE id_spray = $1::SMALLINT`;
			args.length= 1;
			args[0]= toValue(cast(long)result);
		}
		auto ans= conn.execParams(cmdDetail);

		with(cmdSprayDate){
			sqlCommand= `SELECT spray_date
				FROM spray_summary
				WHERE id_spray = $1::INTEGER;`;
			args.length= 1;
			args[0]= toValue(cast(long)result);
		}
		auto ansDate= conn.execParams(cmdSprayDate);

		with(cmdTotalUse){
			sqlCommand= `WITH details AS(
	SELECT spray_summary.spray_date AS spray_date,
		spray_detail.chem_code AS chem_code
	FROM spray_detail INNER JOIN spray_summary
		ON spray_detail.id_spray = spray_summary.id_spray
	WHERE crop_id = $1::INTEGER)

	SELECT COUNT(chem_code) AS num_total_use
	FROM details
	WHERE chem_code = $2::INTEGER
		AND spray_date <= $3::DATE;`;
			args.length= 3;
			args[0]= toValue(selectedIdCrop);
			args[2]= ansDate[0]["spray_date"];
		}

		int idxRow;
		grid.resize(TOTAL_COLUMN_DETAILS, cast(int)(ans.length));
		foreach(scope row; ans.rangify){
//			grid.setCellText(0, idxRow, dtext(row["chem_code"].as!int));
			grid.setCellText(0, idxRow, dtext(listOfPesticides[row["chem_code"].as!int]));
			grid.setCellText(1, idxRow, dtext(row["dilution_num"].as!int));
			grid.setCellText(2, idxRow, dtext(row["dilution_unit"].as!string));
			grid.setCellText(3, idxRow, dtext(row["purpose"].as!string));

			{
				cmdTotalUse.args[1]= row["chem_code"];
				auto ansTotalUse= conn.execParams(cmdTotalUse);
				grid.setCellText(4, idxRow, dtext(ansTotalUse[0]["num_total_use"].as!long));
			}
			++idxRow;
		}
	}
	else{
		result= -1;
	}
	return result;
}
