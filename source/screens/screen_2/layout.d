module screens.screen_2.layout;

import screens.screen_2.layout;

enum string SCREEN_2_LAYOUT= q{
	VerticalLayout{
		TableLayout{
			colCount: 2
//('2022-04-13', 'ズッキーニ', '植え穴散粒', 306, 'g'),
			TextWidget{text: "Date[yyyy-MM-dd]"; fontFace: "IPAゴシック"}
			EditLine{id: widget_2_00; fontFace: "IPAゴシック"}
			TextWidget{text: "使用方法"; fontFace: "IPAゴシック"}
			EditLine{id: widget_2_02; fontFace: "IPAゴシック"}
			TextWidget{text: "使用量（数値）"; fontFace: "IPAゴシック"}
			EditLine{id: widget_2_03; fontFace: "IPAゴシック"}
			TextWidget{text: "使用量（単位）"; fontFace: "IPAゴシック"}
			EditLine{id: widget_2_04; fontFace: "IPAゴシック"}
		}
		HorizontalLayout{
			Button{id: widget_2_05; text: "OK"}
			Button{id: widget_2_06; text: "Cancel"}
		}
	}
};
