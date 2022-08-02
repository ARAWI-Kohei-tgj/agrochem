module screens.screen_2.process; 
/*
import screens.screen_2.layout;
import dpq2;

void screen_2(Connection conn){
	import dlangui;
*/
enum string SCREEN_2= q{
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
	}
	auto elCropName= window_2.mainWidget.childById!EditLine("widget_2_01");
	with(elCropName){
		text(editlineCrop.text);	// external
		fontFace("IPAゴシック");
		minWidth(256);
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
(spray_date, crop_name, spray_type, amount_num, amount_unit) VALUES
($1::DATE, $2::TEXT, $3::TEXT, $4::INTEGER, $5::TEXT);`;
		args.length= 5;
	}

	buttonReg.click= delegate(Widget src) @system{
		if(elDate.text.length > 0
				&& elCropName.text.length > 0
				&& elMethod.text.length > 0
				&& elQuantity.text.length > 0
				&& elUnit.text.length > 0){
			with(cmdReg){
				args[0]= toValue(elDate.text);
				args[1]= toValue(elCropName.text);	// external
				args[2]= toValue(elMethod.text);
				args[3]= toValue(elQuantity.text);
				args[4]= toValue(elUnit.text);
			}

			conn.execParams(cmdReg);

			searchSummary(conn, summaryTree, spraySummary, editlineCrop.text, editlineYear.text);
			getDetails(conn, tableDetails, summaryTree.items.selectedItem);	// external
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