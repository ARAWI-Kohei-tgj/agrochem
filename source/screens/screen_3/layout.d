module screens.screen_3.layout;

enum SCREEN_3_LAYOUT= q{
	VerticalLayout{
		GroupBox{
			text: "spray detail"
			StringGridWidget{
				id: widget_3_00
			}
			HorizontalLayout{
				Button{
					id: widget_3_01
					text: "+"
				}
				Button{
					id: widget_3_02
					text: "−"
				}
			}
		}
		HorizontalLayout{
			TextWidget{text: "NOTE:"}
			TextWidget{id: widget_3_03; text: ""}
			Button{id: widget_3_04; text: "OK"}
			Button{id: widget_3_05; text: "Cancel"}
		}
	}
};
