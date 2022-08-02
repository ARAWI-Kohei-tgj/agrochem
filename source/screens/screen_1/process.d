module screens.screen_1.process;

import dpq2;
import dlangui;
import std.typecons: Tuple, tuple;
import std.datetime: Date;
import postgresql;

enum TOTAL_COLUMN_DETAILS= 5u;

/*************************************************************
 * 
 *************************************************************/
void screen_1(Connection conn){
	import screens.screen_1.layout;

	/**
	 * 
	 **/
	Tuple!(int, "id", Date, "date")[] spraySummary;

	Window window_1= Platform.instance.createWindow("Agrochem",
		null,
		WindowFlag.Resizable | WindowFlag.ExpandSize,
		1080, 640);
	with(window_1){
		mainWidget= parseML(SCREEN_1_LAYOUT);
	}

	{
		import widgets.editline;

		/*****************************************
		 * widgets
		 *****************************************/
		auto editlineYear= window_1.mainWidget.childById!EditLine("widget_1_00");
		with(editlineYear){
			minWidth(64);
			fontSize(24);
		}
/+
		auto editlineCrop= new EditLineCJK();
		editlineCrop.minWidth(128);
		window_1.mainWidget.addChild(editlineCrop);

+/
		auto editlineCrop= window_1.mainWidget.childById!EditLine("widget_1_01");
		with(editlineCrop){
			minWidth(128);
			fontSize(24);
			fontFace("IPAゴシック");
		}

		auto buttonSearch= window_1.mainWidget.childById!Button("widget_1_02");
		auto summaryTree= window_1.mainWidget.childById!TreeWidget("widget_1_03");
		with(summaryTree){
			minHeight(512);
			minWidth(256);
			fontFace("IPAゴシック");
		}

		auto textFieldName= window_1.mainWidget.childById!TextWidget("widget_1_20");

		/// Table 'spray_summary'へ登録
		auto addSummary= window_1.mainWidget.childById!Button("widget_1_08");

		/// Table 'spary_summary'から削除
		auto removeSummary= window_1.mainWidget.childById!Button("widget_1_09");

		/// 終了
		auto buttonQuit= window_1.mainWidget.childById!Button("widget_1_07");
		buttonQuit.click= delegate(Widget src) @system{
			window_1.close;
			return true;
		};

		auto tableDetails= window_1.mainWidget.childById!StringGridWidget("widget_1_04");
		with(tableDetails){
			minWidth(700);
			minHeight(482);
			fontFace("IPAゴシック");
			resize(TOTAL_COLUMN_DETAILS, 1);
			/**
			 * 薬品名, 濃度（数値）, 濃度（単位）, 目的
			 * chem_name, dilution_num, dilution_unit, purpose
			 **/
			setColTitle(0, "薬品名"d);
			setColWidth(1, 200);
			setColTitle(1, "濃度（数値）"d);
			setColTitle(2, "濃度（単位）"d);
			setColTitle(3, "目的"d);
			setColTitle(4, "回数");
			setColWidth(4, 256);
		}

		auto elIdSummary= window_1.mainWidget.childById!EditLine("widget_1_10");
		with(elIdSummary){
			fontFace("IPAゴシック");
			minWidth(64);
		}
		auto elChemName= window_1.mainWidget.childById!EditLine("widget_1_11");
		with(elChemName){
			fontFace("IPAゴシック");
			minWidth(256);
		}
		auto elDilutionNum= window_1.mainWidget.childById!EditLine("widget_1_12");
		with(elDilutionNum){
			fontFace("IPAゴシック");
			minWidth(128);
		}
		auto elDilutionUnit= window_1.mainWidget.childById!EditLine("widget_1_13");
		with(elDilutionUnit){
			fontFace("IPAゴシック");
			minWidth(128);
		}
		auto elPurpose= window_1.mainWidget.childById!EditLine("widget_1_14");
		with(elPurpose){
			fontFace("IPAゴシック");
			minWidth(256);
		}

		auto addDetail= window_1.mainWidget.childById!Button("widget_1_15");
		auto removeDetail= window_1.mainWidget.childById!Button("widget_1_16");

		/*****************************************
		 * 検索ボタン
		 *****************************************/
		buttonSearch.click= delegate(Widget src) @system{
			import std.conv: dtext;
			if(editlineYear.text.length > 0 && editlineCrop.text.length > 0){

				const dstring cropName= editlineCrop.text;
				const dstring yearDtext= editlineYear.text;
				{
					const int year= yearDtext.to!int;
					QueryParams cmd;
					with(cmd){
						sqlCommand= `SELECT fields, seeding, planting
							FROM crop_history
							WHERE crop_name = $1::TEXT
								AND ((seeding IS NOT NULL
									AND seeding >= $2::DATE AND seeding < $3::DATE) OR
									(planting IS NOT NULL
									AND planting >= $2::DATE AND planting < $3::DATE));`;
						args.length= 3;
						args[0]= toValue(cropName);
						args[1]= toValue(Date(year, 1, 1));
						args[2]= toValue(Date(year+1, 1, 1));
					}
					auto ans= conn.execParams(cmd);
					if(ans[0]["fields"].isNull) textFieldName.text("NIL");	// FIXME: row=0 is temp
					else{
						const string[] fields= ans[0]["fields"].as!(string[]);
						textFieldName.text(fields[0].dtext);
					}
				}

				searchSummary(conn, summaryTree, spraySummary, editlineCrop.text, editlineYear.text);
				auto idSelected= getDetails(conn, tableDetails, summaryTree.items.selectedItem);
				if(idSelected > 0) elIdSummary.text= idSelected.to!dstring;
			}
			else{}

			return true;
		};

		/**
		 * Tree
		 */
		summaryTree.selectionChange= delegate(TreeItems src, TreeItem theItem, bool isActivated) @system{
			auto idSelected= getDetails(conn, tableDetails, theItem);
			if(idSelected > 0) elIdSummary.text= idSelected.to!dstring;
		};

		addSummary.click= delegate(Widget src) @system{
			import screens.screen_2.process;

			mixin(SCREEN_2);
			//screen_2(conn);
			return true;
		};

		/**
		 * details
		 */

		 addDetail.click= delegate(Widget src) @system{
			import std.algorithm: all, map, fill;
			import std.conv: text;
			import std.string: isNumeric;
			import std.array: staticArray;

			QueryParams cmd;
			with(cmd){
				sqlCommand= `INSERT INTO spray_detail
(id_spray, chem_name, dilution_num, dilution_unit, purpose) VALUES
($1::INTEGER, $2::TEXT, $3::INTEGER, $4::TEXT, $5::TEXT);`;
				args.length= 5;
			}

			const string[5] strArgs= [elIdSummary.text, elChemName.text,
					elDilutionNum.text, elDilutionUnit.text,
					elPurpose.text].map!(a => a.text).staticArray!5;

			if(strArgs[].all!(a => a.length > 0)){
				if([strArgs[0], strArgs[2]].all!(a => a.isNumeric)){
					cmd.args[].fill(strArgs[].map!(a => toValue(a)));
					conn.execParams(cmd);

					elChemName.text(""d);
					elDilutionNum.text(""d);
					elDilutionUnit.text(""d);
					elPurpose.text(""d);

					getDetails(conn, tableDetails, summaryTree.items.selectedItem);
				}
				else{}
			}
			else{}

			return true;
		};

/+
		addDetail.click= delegate(Widget src) @system{
			import screens.screen_3.process;

			screen_3(conn);
			return true;
		};
+/
	}
	window_1.show;
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

	int result;
	if(branch){
		@(DataBaseAccess.readonly) QueryParams cmdDetail;
		@(DataBaseAccess.readonly) QueryParams cmdTotalUse;
		result= branch.id.to!(typeof(result));
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
				WHERE id_spray = $1::INTEGER`;
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

/**
 *
 **/
import std.string: isNumeric;
void searchSummary(Connection conn, TreeWidget tree, Tuple!(int, "id", Date, "date")[] list,
		const dstring cropName, const dstring year) @system
in(year.length == 4 && year.isNumeric){
	import std.conv: text, dtext;

	// clear buffer
	tree.clearAllItems;

	const string dateSt= year.text ~"-01-01";
	const string dateEn= year.text ~"-12-31";
			

	/*************************************
	 * Initialization
	 *************************************/
	//summaryTree.items= new TreeItems;
	//spraySummary.length= 0;

	/**
	 * summary
	 **/
	QueryParams cmdDateList;
	with(cmdDateList){
		args.length= 3;
		sqlCommand= `SELECT id_spray, spray_date, spray_type
			FROM spray_summary
			WHERE spray_date >= to_date($2::text, 'YYYY-MM-DD')
				AND spray_date <= to_date($3::text, 'YYYY-MM-DD')
				AND crop_name = $1;`;
		args[0]= toValue(cropName);
		args[1]= toValue(dateSt);
		args[2]= toValue(dateEn);
	}

	/**
	 * id_spray, spray_date, crop_name, spray_type, amount_num, amount_unit
	 **/
	auto ans= conn.execParams(cmdDateList);

	{
		import dpq2.conv.time: binaryValueAs;
		import std.array: Appender, appender;
		import std.format: formattedWrite;
		TreeItem foo;
		Appender!string bufID;
		bufID.reserve(3);
		Appender!dstring bufLabel;

		foreach(scope row; ans.rangify){
			bufID= appender!string;
			bufLabel= appender!dstring;
			list ~= tuple!("id", "date")(row["id_spray"].as!int,
				row["spray_date"].binaryValueAs!Date);
			bufID.formattedWrite!"%d"(list[$-1].id);	// example, 3 -> "003"
			bufLabel.formattedWrite!"%s, %s"(list[$-1].date.toISOExtString,
				row["spray_type"].as!string);
			foo= tree.items.newChild(bufID.data, bufLabel.data, null);
		}
		tree.items.selectItem(foo);
	}
}
