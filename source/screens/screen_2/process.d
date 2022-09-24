module screens.screen_2.process; 

import dpq2;
import dlangui;
import utils: SpraySummary;

/**
 * strSpc= yyyy-MM-dd
 */
 /+
bool isValidFormDate(Str)(in Str str) @safe
if(isSomeString!Str){
	if(str.length == 10){
		if((str[0..4] ~str[5..7] ~str[8..10]).all!(a => a.isDigit) &&	// this part must be digits
			str[4] == '-' && str[7] == '-'){	// these are must be hyphen
			return true;
		}
		else{
			return false;
		}
	}
	else{
		return false;
	}
}
+/

void screen_2(Connection conn, in ushort cropId, TreeWidget treeSummary, StringGridWidget tableDetails, SpraySummary[] sprayInfoSummary){
	import screens.screen_1.subroutines: updateSummaryTree, getDetails;

	Window window_2= Platform.instance.createWindow("Agrochem",
		null,
		WindowFlag.Resizable | WindowFlag.ExpandSize,
		640, 256);
	with(window_2){
		import screens.screen_2.layout;
		mainWidget= parseML(SCREEN_2_LAYOUT);
	}

	auto elDate= window_2.mainWidget.childById!EditLine("widget_2_00");
	with(elDate){
		fontFace("IPAゴシック");
		minWidth(256);
/**
 * constraint
 * strSpc= "yyyy-MM-dd"
 */
	}

	auto elMethod= window_2.mainWidget.childById!EditLine("widget_2_02");
	with(elMethod){
		fontFace("IPAゴシック");
		minWidth(256);
	}
	auto elQuantity= window_2.mainWidget.childById!EditLine("widget_2_03");
	with(elQuantity){
		fontFace("IPAゴシック");
		minWidth(256);
	}
	auto elUnit= window_2.mainWidget.childById!EditLine("widget_2_04");
	with(elUnit){
		fontFace("IPAゴシック");
		minWidth(256);
	}
	auto buttonReg= window_2.mainWidget.childById!Button("widget_2_05");
	auto buttonCancel= window_2.mainWidget.childById!Button("widget_2_06");

	window_2.show;

	QueryParams cmdReg;
	with(cmdReg){
		sqlCommand= `INSERT INTO spray_summary
(spray_date, crop_id, spray_type, amount_num, amount_unit) VALUES
($1::DATE, $2::SMALLINT, $3::TEXT, $4::INTEGER, $5::TEXT);`;
		args.length= 5;
	}

	buttonReg.click= delegate(Widget src) @system{
	import screens.screen_1.subroutines: getDetails;
		if(elDate.text.length > 0
				&& elMethod.text.length > 0
				&& elQuantity.text.length > 0
				&& elUnit.text.length > 0){
			with(cmdReg){
				args[0]= toValue(elDate.text);
				args[1]= toValue(cast(short)cropId);
				args[2]= toValue(elMethod.text);
				args[3]= toValue(elQuantity.text);
				args[4]= toValue(elUnit.text);
			}

			conn.execParams(cmdReg);

			updateSummaryTree(conn, treeSummary, cropId, sprayInfoSummary);
			getDetails(conn, tableDetails, treeSummary.items.selectedItem);
			window_2.close;
		}
		else{}
		return true;
	};

	buttonCancel.click= delegate(Widget src) @system{
		window_2.close;
		return true;
	};
};
