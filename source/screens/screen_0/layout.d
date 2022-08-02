module screens.screen_0.layout;

enum string SCREEN_0_LAYOUT= q{
  VerticalLayout{
    margins: 10
    padding: 10
    HorizontalLayout{
      TextWidget{text: "ID"}
      EditLine{id: widget_0_0; text: ""}
    }
    HorizontalLayout{
      TextWidget{text: "Password"}
      EditLine{id: widget_0_1; text: ""}
    }
    HorizontalLayout{
      Button{id: widget_0_2; text: "Login"}
      Button{id: widget_0_3; text: "Quit"}
    }
  }
};


