module screens.screen_1.process;

import dpq2;
import dlangui;
import std.typecons: Tuple, tuple;
import std.traits: isUnsigned, isSomeString;
import std.datetime: Date;
import postgresql;
import utils: SpraySummary;

enum TOTAL_COLUMN_DETAILS= 5u;

struct CropInfo{
	string cropName;
	Date startDate;
	string[] fields;
}

string[uint] listOfPesticides;
short selectedIdCrop, selectedIdSpray;	// FIXME: shared

/*************************************************************
 *  Screen 1
 *************************************************************/
void screen_1(Connection conn){
	import screens.screen_1.layout;
	import std.typecons: Tuple;
	/**
	 * 
	 **/
	//alias CropInfo= Tuple!(short, "id", string, "cropName", Date, "startDate", string[], "fields");
	Tuple!(int, "id", Date, "date")[] spraySummary;
	SpraySummary[] sprayInfoSummary;

	listOfPesticides= (Connection conn) @system{
		import std.algorithm: each;
		string[uint] result;
		QueryParams cmd;
		with(cmd){
			sqlCommand= `SELECT register_code, product_name FROM pesticide_regcode`;
			args.length= 0;
		}
		auto ans= conn.execParams(cmd);
		ans.rangify.each!(row => result[row["register_code"].as!int]= row["product_name"].as!string);
		return result;
	}(conn);

	Window window_1= Platform.instance.createWindow("Agrochem",
		null,
		WindowFlag.Resizable | WindowFlag.ExpandSize,
		1080, 640);
	with(window_1){
		mainWidget= parseML(SCREEN_1_LAYOUT);
	}

	{
		//import widgets.editline;

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
		auto buttonSearch= window_1.mainWidget.childById!Button("widget_1_02");
		auto summaryTree= window_1.mainWidget.childById!TreeWidget("widget_1_03");
		with(summaryTree){
			minHeight(512);
			minWidth(256);
			fontFace("IPAゴシック");
		}

		// crop info
		auto cropListTree= window_1.mainWidget.childById!TreeWidget("widget_1_30");
		with(cropListTree){
			minWidth(512);
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
			minWidth(1024);
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
		auto elChemCode= window_1.mainWidget.childById!EditLine("widget_1_11");
		with(elChemCode){
			fontFace("IPAゴシック");
 			minWidth(128);
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
		 *
		 * Condition:
		 *   start year -> given
		 *
		 * External refference:
		 *   crop_history -> readonly
		 *
		 * step1 播種または定植年を入力
		 * step2 検索ボタン押下
		 * step3 その年に播種または定植された作物一覧を取得
		 * step4 cropListTreeに反映
		 *
		 *****************************************/
		buttonSearch.click= delegate(Widget src) @system{
			import std.conv: text, dtext;
			if(editlineYear.text.length == 0) return true;

			const dstring yearDtext= editlineYear.text;

			/***********************
			 * crop information that seeding or planting in the year 
			 ***********************/
			const CropInfo[ushort] cropList= (in int theYear){
				import dpq2.conv.time: binaryValueAs;
				import std.typecons: Tuple, tuple;
				import std.algorithm;
				import std.array: assocArray;
				import std.range: chain;

				QueryParams cmdSeeding, cmdPlanting;
				Tuple!(ushort, "id", Date, "start")[] startDates;
				CropInfo[ushort] result;

				const yearSt= Date(theYear, 1, 1);
				const yearEn= Date(theYear+1, 1, 1);

				with(cmdSeeding){
					sqlCommand= `SELECT crop_id, MIN(the_date) AS start_date
	FROM seeding_date
	WHERE the_date >= $1::DATE AND the_date < $2::DATE
	GROUP BY crop_id;`;
					args.length= 2;
					args[0]= toValue(yearSt);
					args[1]= toValue(yearEn);
				}
				with(cmdPlanting){
					sqlCommand= `SELECT crop_id, MIN(the_date) AS start_date
	FROM planting_date
	WHERE the_date >= $1::DATE AND the_date < $2::DATE
	GROUP BY crop_id;`;
					args.length= 2;
					args[0]= toValue(yearSt);
					args[1]= toValue(yearEn);
				}

				auto ansSeeding= conn.execParams(cmdSeeding);
				auto ansPlanting= conn.execParams(cmdPlanting);

				foreach(row; chain(ansSeeding.rangify, ansPlanting.rangify)){// FIXME: .sort((a, b) => a.id < b.id)
					startDates ~= tuple!("id", "start")(cast(ushort)(row["crop_id"].as!short),
						row["start_date"].binaryValueAs!Date);
				}
				foreach(idx; 0..startDates.length-1){
					if(startDates[idx].id == startDates[idx+1].id){
						startDates= startDates[0..idx+1] ~startDates[idx+2..$];
					}
					else{}
				}

				QueryParams cmdGetInfo;
				with(cmdGetInfo){
					cmdGetInfo.sqlCommand= `SELECT crop_name, fields
	FROM crop_history
	WHERE crop_id = $1::SMALLINT;`;
					args.length= 1;
				}
				Date[ushort] startDatesById= startDates.assocArray;
				foreach(theId; startDatesById.keys){
					cmdGetInfo.args[0]= toValue(cast(short)(theId));
					auto ans= conn.execParams(cmdGetInfo);
					result[theId]= CropInfo(
						ans[0]["crop_name"].as!string,
						startDatesById[theId],
						ans[0]["fields"].as!(string[]));
				}

				return result;
			}(editlineYear.text.to!int);

			/**
			 * register crop names to cropListTree
			 */
			(ref TreeWidget tree, in CropInfo[ushort] cropList){
				import std.algorithm: map, filter;
				import std.array: Appender, appender, array;
				import std.conv: text, dtext;
				import std.format: formattedWrite;
				import utils: integerToHexStr;

				QueryParams cmdCropNames, cmdCropInfo;
				Appender!dstring bufLabel;
				TreeItem theBranch;

				string[string] dictJpToEn= ["ナス": "Eggplant", "ズッキーニ": "Zucchini",
					"サトイモ": "Taro", "ちぢみほうれん草": "Shrinked_spinach"];// TEMP: move to other file

				const string[] cropNames= cropList.values.map!(a => a.cropName).array;

				foreach(theCropName; cropNames){ 
					theBranch= tree.items.newChild(theCropName, dictJpToEn[theCropName].dtext);

					foreach(elm; cropList.byKeyValue.filter!(a => a.value.cropName == theCropName)){
						bufLabel= appender!dstring;
						bufLabel.formattedWrite!"start=%s, fields=%s"(elm.value.startDate, elm.value.fields);
						theBranch.newChild(integerToHexStr(elm.key), bufLabel.data);
					}
				}

				(in ushort theCropId){
					tree.selectItem(integerToHexStr(theCropId));
					selectedIdCrop= theCropId;
				}(cropList.keys[0]);	// The front element of cropList
			}(cropListTree, cropList);

			{
				import screens.screen_1.subroutines: updateSummaryTree;
				updateSummaryTree(conn, summaryTree, selectedIdCrop, sprayInfoSummary);
			}

			return true;
		};

		/***
		 * Crop list tree
		 ***/

		cropListTree.selectionChange= delegate(TreeItems src, TreeItem theItem, bool isActivated) @system{
			import std.ascii: isHexDigit;
			import std.algorithm: all;
			import utils: hexStrToUshort;
			import screens.screen_1.subroutines: updateSummaryTree;

			if(theItem.id.all!(a => a.isHexDigit)){	// level 2
				selectedIdCrop= hexStrToUshort(theItem.id);
			}
			else{	// level 1
				selectedIdCrop= hexStrToUshort(theItem.child(0).id);	// the front item
				cropListTree.selectItem(theItem.child(0).id);
			}

			updateSummaryTree(conn, summaryTree, selectedIdCrop, sprayInfoSummary);
		};

		/**
		 * Spray list Tree
		 */
		summaryTree.selectionChange= delegate(TreeItems src, TreeItem theItem, bool isActivated) @system{
			import screens.screen_1.subroutines: getDetails;
			auto idSelected= getDetails(conn, tableDetails, theItem);
			if(idSelected > 0) elIdSummary.text= idSelected.to!dstring;
		};

		/**
		 *
		 ***/
		addSummary.click= delegate(Widget src) @system{
			import screens.screen_2.process;

			screen_2(conn, selectedIdCrop, summaryTree, tableDetails, sprayInfoSummary);
			return true;
		};

		/**
		 * details
		 *
		 */
		addDetail.click= delegate(Widget src) @system{
			import std.algorithm: all, map, fill;
			import std.conv: text;
			import std.string: isNumeric;
			import std.array: staticArray;
			import screens.screen_1.subroutines: getDetails;

			QueryParams cmd;
			with(cmd){
				sqlCommand= `INSERT INTO spray_detail
(id_spray, chem_code, dilution_num, dilution_unit, purpose) VALUES
($1::INTEGER, $2::INTEGER, $3::INTEGER, $4::TEXT, $5::TEXT);`;
				args.length= 5;
			}

			const string[5] strArgs= [elIdSummary.text, elChemCode.text,
					elDilutionNum.text, elDilutionUnit.text,
					elPurpose.text].map!(a => a.text).staticArray!5;

			if(strArgs[].all!(a => a.length > 0)){
				if([strArgs[0], strArgs[1], strArgs[2]].all!(a => a.isNumeric)){
					cmd.args[].fill(strArgs[].map!(a => toValue(a)));
					conn.execParams(cmd);

					elChemCode.text(""d);
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
		removeDetail.click= delegate(Widget src) @system{

			return true;
		};
+/
	}
	window_1.show;
}
