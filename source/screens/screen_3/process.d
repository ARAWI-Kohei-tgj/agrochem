module screens.screen_3.process; 

import dpq2;
import dlangui;
void screen_3(Connection conn){
	import screens.screen_3.layout;

	Window window_3= Platform.instance.createWindow("Agrochem",
		null,
		WindowFlag.Resizable | WindowFlag.ExpandSize,
		525, 480);
	with(window_3){
		mainWidget= parseML(SCREEN_3_LAYOUT);
	}

	auto grid= window_3.mainWidget.childById!StringGridWidget("widget_3_00");
	auto buttonAddLine= window_3.mainWidget.childById!Button("widget_3_01");
	auto buttonRemoveLine= window_3.mainWidget.childById!Button("widget_3_02");
	auto textNote= window_3.mainWidget.childById!TextWidget("widget_3_03");
	auto buttonRegst= window_3.mainWidget.childById!Button("widget_3_04");
	auto buttonCancel= window_3.mainWidget.childById!Button("widget_3_05");

	with(grid){
		minWidth(700);
		fontFace("IPAゴシック");
		resize(4, 1);
		/**
		 * 薬品名, 濃度（数値）, 濃度（単位）, 目的
		 * chem_name, dilution_num, dilution_unit, purpose
		 **/
		setColTitle(0, "薬品名"d);
		setColWidth(1, 256);
		setColTitle(1, "濃度（数値）"d);
		setColTitle(2, "濃度（単位）"d);
		setColTitle(3, "目的"d);
		setColWidth(4, 256);
	}

	buttonRegst.click= delegate(Widget src) @system{
		import std.array: appender;
		import std.format: formattedWrite;
		import std.string: isNumeric;
		import std.conv: dtext;

		QueryParams cmd;
		auto buf= appender!string;

		textNote.text= ""d;
		cmd.sqlCommand= "INSERT INTO spray_detail\n
(id_spray, chem_name, dilution_num, dilution_unit, purpose) VALUES\n";

		foreach(idxRow; 0..grid.rows){
			foreach(idxCol; 0..5){
				if(grid.cellText(idxCol, idxRow).length == 0){
					textNote.text= "column "d ~idxCol.dtext ~" is missing.";
					return true;
				}
			}

			if(!grid.cellText(0, idxRow).isNumeric){
				textNote.text("column 0 must be a digit.");
				return true;
			}

			if(!grid.cellText(2, idxRow).isNumeric){
				textNote.text("column 2 must be a digit.");
				return true;
			}

			buf.formattedWrite!"(%s::INTEGER, '%s'::TEXT, %s::INTEGER, '%s'::TEXT, '%s'::TEXT)%c"(
				grid.cellText(0, idxRow),
				grid.cellText(1, idxRow),
				grid.cellText(2, idxRow),
				grid.cellText(3, idxRow),
				grid.cellText(4, idxRow),
				(idxRow < grid.rows-1)? ',': ';'
			);
		}

		cmd.sqlCommand ~= buf.data;
		conn.execParams(cmd);
		window_3.close;
		return true;
	};

	buttonCancel.click= delegate(Widget src) @system{
		window_3.close;
		return true;
	};

	window_3.show;
}
