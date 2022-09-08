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
	foreach(theSpray; sprayInfoSummary){
		tree.items.newChild(integerToHexStr(theSpray.sprayId), theSpray.dateSpray.toISOExtString.dtext);
	}
	tree.selectItem(tree.items.child(tree.items.childCount-1).id);
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

	enum TOTAL_COLUMN_DETAILS= 5u;
	typeof(return) result;
	if(branch){
		@(DataBaseAccess.readonly) QueryParams cmdDetail;
		@(DataBaseAccess.readonly) QueryParams cmdTotalUse;
		result= hexStrToUshort(branch.id);
		/**
		 * buffer clean-up
		 */
		foreach(int idxRow; 0u..grid.rows){
			foreach(int idxCol; 0u..TOTAL_COLUMN_DETAILS) grid.setCellText(idxCol, idxRow, ""d);
		}

		with(cmdDetail){
			sqlCommand= `SELECT chem_name,
					dilution_num,
					dilution_unit,
					purpose
				FROM spray_detail
				WHERE id_spray = $1::SMALLINT`;
			args.length= 1;
			args[0]= toValue(cast(long)result);
		}
		auto ans= conn.execParams(cmdDetail);

		/+
		with(cmdTotalUse){
			sqlCommand= `SELECT count(*)
				FROM spray_detail
				WHERE ;`;
		}
+/
		int idxRow;
		grid.resize(TOTAL_COLUMN_DETAILS, cast(int)(ans.length));
		foreach(scope row; ans.rangify){
			grid.setCellText(0, idxRow, dtext(row["chem_name"].as!string));
			grid.setCellText(1, idxRow, dtext(row["dilution_num"].as!int));
			grid.setCellText(2, idxRow, dtext(row["dilution_unit"].as!string));
			grid.setCellText(3, idxRow, dtext(row["purpose"].as!string));
			//grid.setCellText(4, idxRow,);
			++idxRow;
		}
	}
	else{
		result= -1;
	}
	return result;
}
