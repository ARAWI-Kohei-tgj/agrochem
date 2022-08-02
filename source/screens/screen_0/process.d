module screens.screen_0.process;

import dpq2: Connection;

void screen_0(Connection conn) @system{
	import dlangui;
	import screens.screen_0.layout;

	// create window
	Window window_0= Platform.instance.createWindow("Agrochem", null);

	{
		window_0.mainWidget= parseML(SCREEN_0_LAYOUT);
/*      auto editID= window.mainWidget.childById!EditLine("widget_0_0");
      editID.text;*/

		auto editlineID= window_0.mainWidget.childById!EditLine("widget_0_0");
		editlineID.minWidth(128);
		editlineID.text= "app_2"d;	// TEMP:
		auto editlinePassword= window_0.mainWidget.childById!EditLine("widget_0_1");
		editlinePassword.minWidth(256);
		editlinePassword.text= "e5uqi2fd"d;	// TEMP:
		auto buttonLogin= window_0.mainWidget.childById!Button("widget_0_2");
		buttonLogin.click= delegate(Widget src){
			import std.conv: text;
			import dpq2: ConnectionException;
			import screens.screen_1.process;

			try{
				conn= createConn(text(editlineID.text), text(editlinePassword.text));
/*
	role: app_2
	password: e5uqi2fd
 */
				
			}
			catch(ConnectionException){
				editlineID.text= ""d;
				editlinePassword.text= ""d;
/+
 FIXME: popup window
 +/
			}

			/**
			 * Call screen_1
			 */
			window_0.close;
			screen_1(conn);
			return true;
		};

		auto buttonQuit= window_0.mainWidget.childById!Button("widget_0_3");
		buttonQuit.click= delegate(Widget src){
			window_0.close;
			return true;
		};

	}
	window_0.show;
}

/*************************************************************
 * Function 'createConn'
 *************************************************************/
 Connection createConn(in string loginID, in string password) @system{
	import std.format: format;

	enum string FORMAT_STR= "host=%s port=%s dbname=%s user=%s password=%s";
	enum string host_address= "localhost";
	enum string db_name= "agridb";
	enum string port= "5432";
	immutable  string str= format!FORMAT_STR(host_address, port, db_name, loginID, password);

	return new Connection(str);
};
