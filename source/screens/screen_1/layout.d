module screens.screen_1.layout;

import screens.screen_1.layout;

enum string SCREEN_1_LAYOUT= q{
	VerticalLayout{
		TableLayout{
			colCount: 3
			TextWidget{text: "Year:"}
			TextWidget{text: "Crop:"}
			TextWidget{text: ""}
			EditLine{id: widget_1_00}
			EditLine{id: widget_1_01}
			Button{id: widget_1_02; text: "Search"}
			GroupBox{
				text: "Crop info"
				VerticalLayout{
					HorizontalLayout{
						TextWidget{text: "Field name:"; fontFace: "Nimbus Suns"}
						TextWidget{id: widget_1_20; fontFace: "Nimbus Suns"}
					}
					HorizontalLayout{
						TextWidget{text: "Date of seeding:"; fontFace: "Nimbus Suns"}
						TextWidget{id: widget_1_21}
					}
					HorizontalLayout{
						TextWidget{text: "Date of planting:"; fontFace: "Nimbus Suns"}
						TextWidget{id: widget_1_22}
					}
					HorizontalLayout{
						TextWidget{text: "Status:"; fontFace: "Nimbus Suns"}
						TextWidget{id: widget_1_23}
					}
				}
			}
		}
		HorizontalLayout{
			VerticalLayout{
				GroupBox{
					id: spray_list
					text: "List"
					TreeWidget{id: widget_1_03}
					HorizontalLayout{
						Button{id: widget_1_08; text: "Add"}
						Button{id: widget_1_09; text: "Remove"}
					}
				}
			}
			VerticalLayout{
				GroupBox{
					id: spray_detail
					text: "Detail"
					StringGridWidget{id: widget_1_04}
					HorizontalLayout{
						EditLine{id: widget_1_10}
						EditLine{id: widget_1_11}
						EditLine{id: widget_1_12}
						EditLine{id: widget_1_13}
						EditLine{id: widget_1_14}
					}
					HorizontalLayout{
						Button{id: widget_1_15; text: "Add"}
						Button{id: widget_1_16; text: "Remove"}
					}
				}
			}
		}
		HorizontalLayout{
			Button{id: widget_1_05; text: "Output"}
			Button{id: widget_1_06; text: "Logout"}
			Button{id: widget_1_07; text: "Quit"}
		}
	}
};
